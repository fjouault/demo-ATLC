package fr.eseo.aof.example.classdiagram

import fr.eseo.aof.xtend.utils.AOFAccessors
import org.eclipse.uml2.uml.UMLPackage
import fr.eseo.aof.language.xtend.utils.AOFLanguageAccessors

class UML {
	@AOFLanguageAccessors.Field(source=true)
	var UMLPackage p

	static class AOF1 {
		@AOFAccessors.Field
		var UMLPackage p
	}
}
