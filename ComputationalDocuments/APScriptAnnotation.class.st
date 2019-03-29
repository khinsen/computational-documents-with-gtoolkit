Class {
	#name : #APScriptAnnotation,
	#superclass : #GtAnnotation,
	#instVars : [
		'referencedScript'
	],
	#category : #'ComputationalDocuments-GToolkit'
}

{ #category : #accessing }
APScriptAnnotation class >> possibleParameters [
	^ {
		self constants nameParameterName.
		self constants expandedParameterName.
		self constants showParameterName.
		self constants heightParameterName.
		}
]

{ #category : #rendering }
APScriptAnnotation class >> tag [
	^ #script
]

{ #category : #visitor }
APScriptAnnotation >> accept: aVisitor [
	self flag: 'Do something more specific'.
	^ aVisitor visitAnnotation: self
]

{ #category : #'private - actions' }
APScriptAnnotation >> browseReferenceFrom: anEvent [
	anEvent modifiers isShift ifTrue: [ ^ self ].
	self isScriptDefined ifFalse: [ ^ self inform: 'Script does not exist' ].
	anEvent target fireEvent: (GtPhlowObjectToSpawn new 
		object: self referencedScript;
		sourceElement: anEvent target)
]

{ #category : #'api - style' }
APScriptAnnotation >> cursorLeftInText: aBlRope [
	self utility hideAllButLinkInText: aBlRope forAnnotation: self
]

{ #category : #'accessing - parameter values' }
APScriptAnnotation >> defaultShowSelector [
	^ #gtSourceFor:
]

{ #category : #testing }
APScriptAnnotation >> doesReferenceExist [
	"Return true if a referenced object is defined"
	^ self isScriptDefined 
]

{ #category : #'announcement handling' }
APScriptAnnotation >> handleScriptAnnouncement: aScriptModified [
	self flag: 'adapt'.
	(self referencedScript notNil and: [ 
		aScriptModified classAffected name = self referencedScript parentName  
			and: [ aScriptModified selector = self referencedScript selector ]])
				ifFalse: [ ^ self ].
	self gtDocument styleTextRequest
]

{ #category : #testing }
APScriptAnnotation >> isPreviewDefined [
	"Return true if a preview object is defined"
	^ self isScriptDefined
]

{ #category : #testing }
APScriptAnnotation >> isScriptDefined [
	"Return true if a script is defined in the docuent"
	^ self referencedScript notNil
]

{ #category : #accessing }
APScriptAnnotation >> objectToPreview [
	"Subclasses should define what object to preview"
	^ self referencedScript
]

{ #category : #accessing }
APScriptAnnotation >> referenceParameterName [
	"Return an annotation parameter name that holds a referenced object"
	^ self constants nameParameterName
]

{ #category : #'accessing - parameter values' }
APScriptAnnotation >> referencedScript [
	<return: #APScript or: nil>
	^ referencedScript ifNil: [ referencedScript := self utility 
		valueOf: self constants nameParameterName
		in: self parameters 
		value: [ :aValue | [ self gtDocument storage scriptNamed: aValue asSymbol ]
									on: Error do: [ nil ]] 
		emptyValue: [ nil ] 
		defaultValue: [ nil ] ]
]

{ #category : #subscriptions }
APScriptAnnotation >> registerToSystemChanges [
	self flag: 'add something like ScriptAdded ScriptRemoved, ScriptRenamed'.
	self gtDocument
		subscribe: GtDocumentUpdateRequestedAnnouncement
			send: #handleDocumentUpdateRequestedAnnouncement:
			to: self
			for: self gtSubscriber.
]

{ #category : #'api - style' }
APScriptAnnotation >> styleTextWithMarkup: aBlRope [
	super styleTextWithMarkup: aBlRope.
	self styleLinkInText: aBlRope.
	self styleExpandingPreviewInText: aBlRope.
	self registerToSystemChanges
]

{ #category : #'api - style' }
APScriptAnnotation >> styleTextWithoutInteractions: aBlRope [
	| aLinkNode |
	aLinkNode := self utility linkNodeForAnnotation: self.
	(aBlRope from: aLinkNode start to: aLinkNode stop) glamorousCodeFont.
	self utility hideAllButLinkInText: aBlRope forAnnotation: self.
]

{ #category : #'api - style' }
APScriptAnnotation >> styleTextWithoutMarkup: aBlRope [
	self styleTextWithMarkup: aBlRope.
	super styleTextWithoutMarkup: aBlRope.
	(self utility mayHideAllButLinkInText: aBlRope forAnnotation: self) ifFalse: [ ^ self ].
	self utility styleCursorAttributeInText: aBlRope forNode: self.
]
