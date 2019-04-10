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
		self constants previewExpandedParameterName.
		self constants previewHeightParameterName.
		}
]

{ #category : #rendering }
APWikiLinkAnnotation class >> tag [
	^ #wikiPage
]

{ #category : #'private - actions' }
APWikiLinkAnnotation >> browseReferenceFrom: anEvent [
	anEvent modifiers isShift ifTrue: [ ^ self ].
	self isPageDefined ifFalse: [ self createReferencedPage ].
	anEvent target fireEvent: (GtPhlowObjectToSpawn new 
		object: self referencedPage;
		sourceElement: anEvent target)
]

{ #category : #'accessing - parameter values' }
APWikiLinkAnnotation >> createReferencedPage [
	^ referencedPage ifNil: [ referencedPage := self utility 
		valueOf: self constants nameParameterName
		in: self parameters 
		value: [ :aValue | [ self gtDocument storage createOrRetrieveWikiPageNamed: aValue asSymbol ]
									on: Error do: [ nil ]] 
		emptyValue: [ nil ] 
		defaultValue: [ nil ] ]
]

{ #category : #'api - style' }
APWikiLinkAnnotation >> cursorLeftInText: aBlRope [
	"This is called when the cursor moves into the markup, but it's not clear what good it does.
	 Leaving it out doesn't seem to make any difference."
	self utility hideAllButLinkInText: aBlRope forAnnotation: self
]

{ #category : #'accessing - parameter values' }
APWikiLinkAnnotation >> defaultShowSelector [
	^ #gtDocumentFor:
]

{ #category : #testing }
APWikiLinkAnnotation >> doesReferenceExist [
	"Return true if a referenced object is defined."
	^ true
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
APWikiLinkAnnotation >> styleLinkInText: aBlRope [
	| aNodeToStyle aLinkColor theAttributes |
	aLinkColor := self utility linkColor: self isPageDefined.
	theAttributes := Array with: (BlTextForegroundAttribute new paint: aLinkColor)
								 with: (BrTextHoverStylableAttribute new
											attribute: (BlTextUnderlineAttribute new paint: aLinkColor))
								 with: (BrTextClickAttribute new
											action: [ :aText :aTarget :aTextEditor :anEvent | 
												self browseReferenceFrom: anEvent ]).

	aNodeToStyle := self utility linkNodeForAnnotation: self.
	(aBlRope  
		from: aNodeToStyle start 
		to: (aNodeToStyle start max: aNodeToStyle stop))
			attributes: theAttributes.

]

{ #category : #'api - style' }
APWikiLinkAnnotation >> styleTextWithMarkup: aBlRope [
	super styleTextWithMarkup: aBlRope.
	self styleLinkInText: aBlRope.
	self styleExpandingPreviewInText: aBlRope.
	self registerToSystemChanges
]

{ #category : #'api - style' }
APWikiLinkAnnotation >> styleTextWithoutMarkup: aBlRope [
	"First render the full text with markup"
	self styleTextWithMarkup: aBlRope.
	"The hide the markup, or not, return true if something was hidden"
	(self utility mayHideAllButLinkInText: aBlRope forAnnotation: self)
		"If something was hidden, put it back if the cursor is nearby"
		ifTrue: [ self utility styleCursorAttributeInText: aBlRope forNode: self ].

]
