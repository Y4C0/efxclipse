/*
 * generated by Xtext
 */
package org.eclipse.fx.ide.l10n.generator

import java.util.HashSet
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.fx.ide.l10n.nLSDsl.MessageEntry
import org.eclipse.fx.ide.l10n.nLSDsl.NLS
import org.eclipse.fx.ide.l10n.nLSDsl.NLSBundle
import org.eclipse.fx.ide.l10n.nLSDsl.PredefinedTypes
import org.eclipse.fx.ide.l10n.nLSDsl.RichString
import org.eclipse.fx.ide.l10n.nLSDsl.RichStringLiteral
import org.eclipse.fx.ide.l10n.nLSDsl.RichStringLiteralEnd
import org.eclipse.fx.ide.l10n.nLSDsl.RichStringLiteralInbetween
import org.eclipse.fx.ide.l10n.nLSDsl.RichStringLiteralStart
import org.eclipse.fx.ide.l10n.nLSDsl.RichVarPart
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator

/**
 * Generates code from your model files on save.
 *
 * see http://www.eclipse.org/Xtext/documentation.html#TutorialCodeGeneration
 */
class NLSDslGenerator implements IGenerator {

	override void doGenerate(Resource resource, IFileSystemAccess fsa) {
		val root = resource.contents.head as NLS

		root.bundleList.forEach[b|
			handleBundle(root,b,fsa)
		]
	}

	def handleBundle(NLS root, NLSBundle b, IFileSystemAccess fsa) {
		fsa.generateFile(root.package.name.replace(".","/")+"/"+b.name+".properties",b.genPropertyFile(b.lang))
		fsa.generateFile(root.package.name.replace(".","/")+"/"+b.name+".java",b.genClass(root))
		fsa.generateFile(root.package.name.replace(".","/")+"/"+b.name+"Registry.java",b.genRegistryClass(root))

		val set = new HashSet<String>
		b.messageEntryList.fold(set,[r,s|
			r.addAll(s.messageList.filter[m|m.name != null].map[m|m.name])
			return r;
		]).forEach[lang|
			fsa.generateFile(root.package.name.replace(".","/")+"/"+b.name+"_"+lang+".properties",b.genPropertyFile(lang))
		]
	}

	def genClass(NLSBundle nls, NLS root) '''
	package «root.package.name»;

	/*
	 * Do not modify - Auto generated from «root.eResource.URI.lastSegment»
	 */
	public class «nls.name» {
		«FOR me : nls.messageEntryList.filter[m|m.entryRef == null]»
			public String «me.name»;
		«ENDFOR»
	}
	'''

	def genRegistryClass(NLSBundle nls, NLS root) '''
	package «root.package.name»;

	/*
	 * Do not modify - Auto generated from «root.eResource.URI.lastSegment»
	 */
	@org.eclipse.e4.core.di.annotations.Creatable
	public class «nls.name»Registry extends org.eclipse.fx.core.di.text.AbstractMessageRegistry<«nls.name»> {
		«IF nls.eAllContents.filter(typeof(RichVarPart)).findFirst[p|p.findFormatter == "-number"] != null»
		@javax.inject.Inject
		private org.eclipse.fx.core.di.text.NumberFormatter _number;
		«ENDIF»

		«IF nls.eAllContents.filter(typeof(RichVarPart)).findFirst[p|p.findFormatter == "-date"] != null»
		@javax.inject.Inject
		private org.eclipse.fx.core.di.text.DateFormatter _date;
		«ENDIF»

		«IF nls.eAllContents.filter(typeof(RichVarPart)).findFirst[p|p.findFormatter == "-temporal"] != null»
		@javax.inject.Inject
		private org.eclipse.fx.core.di.text.TemporalAccessorFormatter _temporal;
		«ENDIF»

		«FOR f : nls.formatterList»
		@javax.inject.Inject
		private «f.classRef» cust_«f.name»;
		«ENDFOR»

		«FOR b : nls.messageEntryList.filter[m|m.entryRef != null].fold(new HashSet,[s,e|
			s.add(e.entryRef.findNLSBundle)
			return s
		])»
		@javax.inject.Inject
		private «(b.eContainer as NLS).package.name».«b.name»Registry bundle_«b.name»;
		«ENDFOR»

		@javax.inject.Inject
		public void updateMessages(@org.eclipse.e4.core.services.nls.Translation «nls.name» messages) {
			super.updateMessages(messages);
		}

		«FOR me : nls.messageEntryList»
			public String «me.name»() {
				«IF me.entryRef != null»
				return bundle_«me.entryRef.findNLSBundle.name».«me.entryRef.name»();
				«ELSE»
				return getMessages().«me.name»;
				«ENDIF»
			}

			«IF ! me.paramList.empty»
				public String «me.name»(«me.paramList.map[p|p.predefined.toSourceString + " " + p.^var].join(", ")») {
					«IF me.entryRef != null»
						return bundle_«me.entryRef.findNLSBundle.name».«me.entryRef.name»(«me.paramList.map[p|p.^var].join(", ")»);
					«ELSE»
						java.util.Map<String,Object> dataMap = new java.util.HashMap<>();
						«FOR p : me.paramList»
							dataMap.put("«p.^var»",«p.^var»);
						«ENDFOR»
						«IF me.messageList.head.message.expressions.filter(typeof(RichVarPart)).findFirst[p|p.format!= null] != null»
							java.util.Map<String,org.eclipse.fx.core.text.Formatter<?>> formatterMap = new java.util.HashMap<>();
							«FOR o : me.messageList.head.message.expressions.filter(typeof(RichVarPart)).filter[p|p.format != null].map[findFormatter].fold(new HashSet,[ s,p |
								s.add(p)
								return s
							])»
								«IF o == "-default"»
								formatterMap.put("«o»",org.eclipse.fx.core.text.Formatter.TO_STRING);
								«ELSEIF o == "-date"»
								formatterMap.put("«o»",_date);
								«ELSEIF o == "-number"»
								formatterMap.put("«o»",_number);
								«ELSEIF o == "-temporal"»
								formatterMap.put("«o»",_temporal);
								«ELSE»
								formatterMap.put("«o»",cust_«o»);
								«ENDIF»
							«ENDFOR»
							return org.eclipse.fx.core.text.MessageFormatter.create(dataMap::get,formatterMap::get).apply( «me.name»() );
						«ELSE»
							return org.apache.commons.lang.text.StrSubstitutor.replace( «me.name»(), dataMap);
						«ENDIF»
					«ENDIF»
				}

				public java.util.function.Supplier<String> «me.name»_supplier(«me.paramList.map[p|p.predefined.toSourceString + " " + p.^var].join(", ")») {
					return () -> «me.name»(«me.paramList.map[p|p.^var].join(", ")»);
				}
			«ENDIF»

		«ENDFOR»
	}
	'''

	def toSourceString(PredefinedTypes t) {
		if( t == PredefinedTypes::ANY ) {
			return "Object"
		} else if( t == PredefinedTypes::DATE ) {
			return "java.util.Date"
		} else if( t == PredefinedTypes::TEMPORAL ) {
			return "java.time.temporal.TemporalAccessor";
		} else {
			return "Number"
		}
	}

	def genPropertyFile(NLSBundle nls, String lang) '''
	#
	# Do not modify - Auto generated from «nls.eResource.URI.lastSegment»
	#
	«FOR e : nls.messageEntryList.filter[m|m.messageList.findFirst[mm|mm.name == lang] != null]»
		«e.name» = «e.messageList.findFirst[m|m.name == lang].message.toText»
	«ENDFOR»
	'''

	def toText(RichString r) {
		return r.expressions.map[e|
			if( e instanceof RichStringLiteral ) {
				return e.value.substring(3,e.value.length-3)
			} else if( e instanceof RichStringLiteralStart ) {
				return e.value.substring(3,e.value.length-1)
			} else if( e instanceof RichStringLiteralEnd ) {
				return e.value.substring(1,e.value.length-3)
			} else if( e instanceof RichVarPart ) {
				return "${" + e.key + if( e.format != null ) { "," + e.findFormatter +"," + e.format } + "}" else "}"
			} else if( e instanceof RichStringLiteralInbetween ) {
				return e.value.substring(1,e.value.length-1)
			}
			return e.toString
		].join
	}

	def findFormatter(RichVarPart p) {
		if( p.formatterClass != null ) {
			return p.formatterClass.name
		} else {
			switch(p.findMessageEntry.paramList.findFirst[param|param.^var == p.key].predefined) {
				case DATE: return "-date"
				case NUMBER: return "-number"
				case TEMPORAL: return "-temporal"
				default: return "-default"
			}
		}
	}

	def NLSBundle findNLSBundle(EObject e) {
		if( e.eContainer instanceof NLSBundle ) {
			return e.eContainer as NLSBundle
		}

		return e.eContainer?.findNLSBundle
	}

	def MessageEntry findMessageEntry(EObject e) {
		if( e.eContainer instanceof MessageEntry ) {
			return e.eContainer as MessageEntry
		}

		return e.eContainer?.findMessageEntry
	}
}
