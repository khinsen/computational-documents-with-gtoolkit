Class {
	#name : #APWikiLinkAnnotation,
	#superclass : #GtAnnotation,
	#instVars : [
		'referencedPage'
	],
	#category : #ComputationalDocuments
}

{ #category : #accessing }
APWikiLinkAnnotation class >> possibleParameters [
	^ {
		self constants nameParameterName.
		}
]

{ #category : #rendering }
APWikiLinkAnnotation class >> tag [
	^ #wikiPage
]

{ #category : #'private - actions' }
APWikiLinkAnnotation >> browseReferenceFrom: anEvent [
	anEvent modifiers isShift ifTrue: [ ^ self ].
	self isPageDefined ifFalse: [ ^ self inform: 'Script does not exist' ].
	anEvent target fireEvent: (GtPhlowObjectToSpawn new 
		object: self referencedPage;
		sourceElement: anEvent target)
]

{ #category : #'api - style' }
APWikiLinkAnnotation >> cursorLeftInText: aBlRope [
	self utility hideAllButLinkInText: aBlRope forAnnotation: self
]

{ #category : #'accessing - parameter values' }
APWikiLinkAnnotation >> defaultShowSelector [
	^ #gtDocumentFor:
]

{ #category : #testing }
APWikiLinkAnnotation >> doesReferenceExist [
	"Return true if a referenced object is defined"
	^ self isPageDefined 
]

{ #category : #testing }
APWikiLinkAnnotation >> isPageDefined [
	"Return true if a script is defined in the docuent"
	^ self referencedPage notNil
]

{ #category : #testing }
APWikiLinkAnnotation >> isPreviewDefined [
	"Return true if a preview object is defined"
	^ self isPageDefined
]

{ #category : #accessing }
APWikiLinkAnnotation >> objectToPreview [
	"Subclasses should define what object to preview"
	^ self referencedPage
]

{ #category : #accessing }
APWikiLinkAnnotation >> referenceParameterName [
	"Return an annotation parameter name that holds a referenced object"
	^ self constants nameParameterName
]

{ #category : #'accessing - parameter values' }
APWikiLinkAnnotation >> referencedPage [
	^ referencedPage ifNil: [ referencedPage := self utility 
		valueOf: self constants nameParameterName
		in: self parameters 
		value: [ :aValue | [ self gtDocument storage wikiPageNamed: aValue asSymbol ]
									on: Error do: [ nil ]] 
		emptyValue: [ nil ] 
		defaultValue: [ nil ] ]
]

{ #category : #subscriptions }
APWikiLinkAnnotation >> registerToSystemChanges [
	self gtDocument
		subscribe: GtDocumentUpdateRequestedAnnouncement
			send: #handleDocumentUpdateRequestedAnnouncement:
			to: self
			for: self gtSubscriber.
]

{ #category : #'api - style' }
APWikiLinkAnnotation >> styleTextWithMarkup: aBlRope [
	super styleTextWithMarkup: aBlRope.
	self styleLinkInText: aBlRope.
	self styleExpandingPreviewInText: aBlRope.
	self registerToSystemChanges
]

{ #category : #'api - style' }
APWikiLinkAnnotation >> styleTextWithoutInteractions: aBlRope [
	| aLinkNode |
	aLinkNode := self utility linkNodeForAnnotation: self.
	(aBlRope from: aLinkNode start to: aLinkNode stop) glamorousCodeFont.
	self utility hideAllButLinkInText: aBlRope forAnnotation: self.
]

{ #category : #'api - style' }
APWikiLinkAnnotation >> styleTextWithoutMarkup: aBlRope [
	self styleTextWithMarkup: aBlRope.
	super styleTextWithoutMarkup: aBlRope.
	(self utility mayHideAllButLinkInText: aBlRope forAnnotation: self) ifFalse: [ ^ self ].
	self utility styleCursorAttributeInText: aBlRope forNode: self.
]
