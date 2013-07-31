package org.eclipse.fx.ide.fxgraph.converter

import java.util.Stack
import org.eclipse.fx.ide.fxgraph.fXGraph.Element
import org.eclipse.fx.ide.fxgraph.fXGraph.FXGraphFactory
import org.eclipse.fx.ide.fxgraph.fXGraph.Model
import org.xml.sax.Attributes
import org.xml.sax.SAXException
import org.xml.sax.helpers.DefaultHandler
import org.eclipse.xtext.common.types.TypesFactory
import javax.inject.Inject
import org.eclipse.xtext.common.types.access.IJvmTypeProvider
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import javax.xml.parsers.SAXParserFactory

class FXMLSaxHandler extends DefaultHandler {
	public Model model;

	Stack<Object> stack = new Stack;
	
//	@Inject
//	private IJvmTypeProvider.Factory jdtTypeProviderFactory;

//	private IJvmTypeProvider jdtTypeProvider;

	private String packageName;

	new(String packageName)
	{
		this.packageName = packageName;
	}

	override startDocument() throws SAXException {
//		jdtTypeProvider = jdtTypeProviderFactory.findOrCreateTypeProvider(new ResourceSetImpl)
		model = FXGraphFactory.eINSTANCE.createModel
		val pack = FXGraphFactory.eINSTANCE.createPackageDeclaration
		pack.setName(packageName)
		model.setPackage(pack)
		
		val componentDef = FXGraphFactory.eINSTANCE.createComponentDefinition
		model.componentDef = componentDef
	}
	
	override processingInstruction(String target, String data) throws SAXException {
		if ("import" == target) {
			val i = FXGraphFactory.eINSTANCE.createImport
			i.importedNamespace = data
			model.imports += i
		}
	}
	
	override startElement(String uri, String localName, String qName, Attributes attributes) throws SAXException {
		if( localName.contains('.') ) {
			// A static property
			val e = stack.peek as Element
			val prop = FXGraphFactory.eINSTANCE.createStaticValueProperty
			
			e.staticProperties.add(prop);
			stack.push(prop)			
		} else if( Character.isLowerCase(localName.charAt(0)) ) {
			// A property
			val e = stack.peek as Element
			val prop = FXGraphFactory.eINSTANCE.createProperty
			val vProp = FXGraphFactory.eINSTANCE.createSimpleValueProperty
			
			e.properties.add(prop)
			
			stack.push(prop)
		} else {
			// An element
			val e = FXGraphFactory.eINSTANCE.createElement
			
			val t = TypesFactory.eINSTANCE.createJvmParameterizedTypeReference()
			val jvmType = TypesFactory.eINSTANCE.createJvmPrimitiveType()
			jvmType.simpleName = localName
			t.type = jvmType
			e.type = t
			
			if( model.componentDef.rootNode == null ) {
				model.componentDef.rootNode = e
			}
		
			stack.push(e)
		}
	}
	
	override endElement(String uri, String localName, String qName) throws SAXException {
		stack.pop
	}
}