Class {
	#name : #APWikiPage,
	#superclass : #Object,
	#instVars : [
		'wiki',
		'name',
		'text'
	],
	#category : #ComputationalDocuments
}

{ #category : #'instance creation' }
APWikiPage class >> wiki: anAPWiki name: aSymbol text: aString [
	^self basicNew
			initializeWithWiki: anAPWiki name: aSymbol text: aString;
			yourself
]

{ #category : #inspecting }
APWikiPage >> asGtDocument [
	^ GtDocument new
					 strategy: (APWikiPageStorageStrategy new container: wiki; name: name);
					 read
]

{ #category : #inspecting }
APWikiPage >> gtDocumentFor: aView [
	<gtView>
	| aGtDocument |
	aGtDocument := self asGtDocument.
	^ (aGtDocument gtTextFor: aView)
		title: name;
		priority: -1;
		action: [ :anAction | 
			aGtDocument gtSaveActionFor: anAction ];
		action: [ :anAction | 
			aGtDocument gtShowMarkupActionFor: anAction ]
]

{ #category : #initialization }
APWikiPage >> initializeWithWiki: anAPWiki name: aSymbol text: aString [
	wiki := anAPWiki.
	name := aSymbol.
	text := aString
]

{ #category : #accessing }
APWikiPage >> name [
	^ name
]

{ #category : #printing }
APWikiPage >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(;
			  nextPutAll: name;
			  nextPut: $).

]

{ #category : #accessing }
APWikiPage >> text [
	^ text
]

{ #category : #accessing }
APWikiPage >> text: anObject [
	text := anObject
]

{ #category : #accessing }
APWikiPage >> wiki [
	^ wiki
]
