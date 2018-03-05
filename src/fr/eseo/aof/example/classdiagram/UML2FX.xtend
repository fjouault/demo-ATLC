package fr.eseo.aof.example.classdiagram

import fr.eseo.aof.constraints.Strength
import fr.eseo.aof.constraints.cassowary.CassowarySolver
import fr.eseo.aof.constraints.geometry.javafx.JFXBinding
import fr.eseo.aof.language.constraints.RuleExtensions.Rule2Constrained
import fr.eseo.aof.language.core.Rule
import fr.eseo.aof.language.core.Rule.Rule2
import fr.eseo.aof.language.core.javafx.JFXExtension
import fr.eseo.aof.language.core.javafx.JFXExtension.JFX
import fr.eseo.aof.language.core.javafx.JFXInteractions
import javafx.geometry.VPos
import javafx.scene.input.MouseButton
import javafx.scene.paint.Paint
import javafx.scene.shape.Line
import javafx.scene.shape.Rectangle
import javafx.scene.text.Text
import org.eclipse.papyrus.aof.core.IBox
import org.eclipse.uml2.uml.Association
import org.eclipse.uml2.uml.Class
import org.eclipse.uml2.uml.Package
import org.eclipse.uml2.uml.PackageableElement

class UML2FX {
	extension JFXExtension = new JFXExtension
	public extension UML uml = new UML
	public extension UML.AOF1 uml1 = new UML.AOF1
	extension JFXBinding = new JFXBinding
	public extension Rule<?, ?> ruleExt = new Rule.Rule1(null)

	private var dx = 0.0;
	private var dy = 0.0; 
	
	public val Rule2<Package, Rectangle, Text> Package2Rectangle =
		new Rule2Constrained<Package, Rectangle, Text>(
			to(
				JFX.Rectangle,
				fill <=> name.collect[Paint.valueOf("#ADD8E6E0")],
				stroke <=> name.collect[Paint.valueOf("black")],
				onDrag,
				onPress
			),
			to(
				JFX.Text,
				stroke <=> name.collect[Paint.valueOf("black")],
				text <=> name,
				origin <=> name.collect[VPos.TOP],
				mouseTransparent <=> name.collect[true]
			)
		).constraints [ p, r, t |#[
			r.topLeft.stay(Strength.MEDIUM),
			r.topLeft.suggest(90,120),
			r.height2.minimize(Strength.WEAK),
			r.width2.minimize(Strength.WEAK),
			t.topLeft == r.topLeft.dx(5),
			r.width2 >= 100,
			r.height2 >= 100,
			r.contains(p._packagedElement.classes),
			r.contains(p._packagedElement.packages)
		]]
	
	public val Rule2<Class, Rectangle, Text> Class2Rectangle = 
		new Rule2Constrained<Class, Rectangle, Text>(
			to(JFX.Rectangle,
				fill <=> name.collect[Paint.valueOf("white")],
				stroke <=> name.collect[Paint.valueOf("black")],
				onDrag,
				onPress
			),
			to(JFX.Text,
				stroke <=> name.collect[Paint.valueOf("black")],
				text <=> name,
				origin <=> name.collect[VPos.TOP],
				mouseTransparent <=> name.collect[true]
			)
		).constraints[c, r, t| #[
			r.topLeft.stay(Strength.MEDIUM),
			r.topLeft.suggest(350,350),
			r.height2.minimize(Strength.MEDIUM),
			r.width2.minimize(Strength.MEDIUM),
			r.height2 >= 25,
			r.width2 >= t.width,
			t.topLeft.x == r.topLeft.x,
			t.topLeft.y == r.topLeft.y + 5,
			r.bottomRight.y >= t.rectangle.bottomRight.y
		]]
	
	public var Rule2<Association,Line,Text> Association2Line =
		new Rule2Constrained<Association,Line,Text>(
			to(JFX.Line,
				stroke <=> name.collect[Paint.valueOf("black")]
			),
			to(JFX.Text,
				stroke <=> name.collect[Paint.valueOf("black")],
				text <=> name,
				origin <=> name.collect[VPos.TOP]
			)
		).constraints[a,l,t| #[
			t.rectangle.bottomLeft == l.line.center,
			a._memberEnd.first.type.select(Class).collectTo(Class2Rectangle).a.rectangle_.contains(l.start),
			a._memberEnd.second.type.select(Class).collectTo(Class2Rectangle).a.rectangle_.contains(l.end),
			l.start.minimizeDistance(l.end)<> Strength.WEAK
		]]
		
		
	def classes(IBox<PackageableElement> b) {
		b.select(Class).collectTo(Class2Rectangle).a.rectangle_
	}
	
	def packages(IBox<PackageableElement> b) {
		b.select(Package).collectTo(Package2Rectangle).a.rectangle_
	}
	
	def <A> first(IBox<A> b) {
		b.asOption
	}

	def <A> second(IBox<A> b) {
		b.excluding(b.first).first
	}
	
	def <A> last(IBox<A> b) {
		var a = b;
		var last = b.first;
		while(!a.first.isEmpty.get(0)){
			last = a.first;
			a = a.excluding(a.first)
		}
		last;
	}
		
	def <A> excluding(IBox<A> b, IBox<A> toExclude) {
		b.selectMutable[e |
			toExclude.select[f |
				f === e
			].isEmpty
		]
	}

	def onPress() {
		JFXInteractions.onPress[e, s, t|
			val r = t as Rectangle
			dx = e.x - r.x
			dy = e.y - r.y
		]
	}

	def onDrag() {
		JFXInteractions.onDrag [ e, s, t |
			val r = t as Rectangle
			switch (e.button) {
				case MouseButton.PRIMARY: {
					r.x = e.x - dx
					r.y = e.y - dy

					CassowarySolver.INSTANCE.solve
					e.consume
				}
				default: {
				}
			}
		]
	}
}
