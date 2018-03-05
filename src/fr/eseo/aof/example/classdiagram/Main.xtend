package fr.eseo.aof.example.classdiagram

import fr.eseo.aof.constraints.cassowary.CassowarySolver
import fr.eseo.aof.language.core.Rule
import javafx.application.Application
import javafx.scene.Group
import javafx.scene.Node
import javafx.scene.Scene
import javafx.scene.input.KeyEvent
import javafx.scene.layout.BorderPane
import javafx.scene.layout.Pane
import javafx.stage.Stage
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.papyrus.aof.emf.EMFFactory
import org.eclipse.uml2.uml.AggregationKind
import org.eclipse.uml2.uml.Model
import org.eclipse.uml2.uml.UMLPackage
import org.eclipse.uml2.uml.resource.UMLResource

import static extension fr.eseo.aof.example.classdiagram.UML.AOF1.*
import static extension fr.eseo.aof.language.constraints.javafx.JFXExtensions.toBox

class Main extends Application {
	var ResourceSet rs
	var Resource sourceRes
	
	def static void main(String[] args) {
		launch(args)
	}
	
	
	override start(Stage stage) throws Exception {
		extension val fr.eseo.aof.example.classdiagram.UML.AOF1 uml1 = new fr.eseo.aof.example.classdiagram.UML.AOF1
		
		uml1.StructuredClassifier.defaultInstance = uml1.Class.defaultInstance 
		uml1.Classifier.defaultInstance = uml1.Class.defaultInstance 
		uml1.TypedElement.defaultInstance = uml1.Property.defaultInstance

		val root = new Pane
		val tRoot = new Group
		root.children.add(tRoot)

		val borderPane = new BorderPane
		borderPane.center = root

		val scene = new Scene(borderPane, 800, 800)
		stage.scene = scene
		stage.title = "UML Class Diagram to JavaFX"
		stage.maximized = true
		stage.show
		
		//Load model
		rs = new ResourceSetImpl
		rs.resourceFactoryRegistry.extensionToFactoryMap.put(
			UMLResource.FILE_EXTENSION,
			UMLResource.Factory.INSTANCE
		)
		rs.packageRegistry.put(
			UMLPackage.eNS_URI,
			UMLPackage.eINSTANCE
		)
		sourceRes = rs.getResource(URI.createFileURI("resources/demo_class_Diagram.uml"), true)
		val s = sourceRes.contents.get(0) as Model

		val package = EMFFactory.INSTANCE.createPropertyBox(
			s,
			UMLPackage.eINSTANCE.package_PackagedElement
		).select(Package)
		val packages = package.union(
			package.packagedElement.select(Package)
		)
		
		val classes = packages.packagedElement.select(Class)
		val associations = EMFFactory.INSTANCE.createPropertyBox(
			s,
			UMLPackage.eINSTANCE.package_PackagedElement
		).select(Association)
		

		// create the transformation
		val transfo = new fr.eseo.aof.example.classdiagram.UML2FX
		extension val Rule<?, ?> ruleExt = transfo.ruleExt

		val packagesTransformed = packages.collectTo(transfo.Package2Rectangle)
		val classesTransformed = classes.collectTo(transfo.Class2Rectangle)
		val associationsTransformed = associations.select[
			it.memberEnds.forall[
				it.aggregation === AggregationKind.NONE_LITERAL
			]
		].collectTo(transfo.Association2Line)
		
		
		tRoot.children.toBox.bind(
				packagesTransformed.a.collect[it as Node]
			.concat(
				packagesTransformed.b.collect[it as Node]
			).concat(
				associationsTransformed.a.collect[it as Node]
			).concat(
				associationsTransformed.b.collect[it as Node]
			) .concat(
				classesTransformed.a.collect[it as Node]
			).concat(
				classesTransformed.b.collect[it as Node]
			)
		)
		
		//Quit app on escape keypress
		//Display debug info of solver with space
		scene.addEventHandler(KeyEvent.KEY_PRESSED, [KeyEvent t |
		    switch t.getCode {
				case ESCAPE: {
					stage.close
				}
				case SPACE: {
					println(CassowarySolver.INSTANCE)
				}
				default: {
				}
			}
		]);
		
	}
}
