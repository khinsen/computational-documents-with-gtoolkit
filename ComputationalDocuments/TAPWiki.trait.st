Trait {
	#name : #TAPWiki,
	#category : #ComputationalDocuments
}

{ #category : #inspecting }
TAPWiki classSide >> gtDocumentFor: aView [
	<gtView>
	| aDocument |
	aDocument := GtDocument new
							strategy: (APWikiPageStorageStrategy new container: self; name: #Main);
							read.
	^ (aDocument gtTextFor: aView)
		title: 'Main page';
		priority: -1;
		action: [ :anAction | 
			aDocument gtSaveActionFor: anAction ];
		action: [ :anAction | 
			aDocument gtShowMarkupActionFor: anAction ]
]

{ #category : #testing }
TAPWiki classSide >> hasWikiPageNamed: aSymbol [
	^ aSymbol = #Main
		or: [ self respondsTo: (self methodSelectorForWikiPageNamed: aSymbol) ]
]

{ #category : #accessing }
TAPWiki classSide >> methodSelectorForWikiPageNamed: aSymbol [
	^ ('wikiPage', aSymbol capitalized) asSymbol
]

{ #category : #accessing }
TAPWiki classSide >> store: aString inWikiPageNamed: aSymbol [
	| code |

	aSymbol = #Main
		ifTrue: [ self comment: aString. ^ self ].

	code := String streamContents: [ :s |
		s nextPutAll: (self methodSelectorForWikiPageNamed: aSymbol).
		s crtab; nextPutAll: '"This method was automatically generated."'.
		s crtab; nextPutAll: '<wikiPage: '; nextPutAll: aSymbol storeString; nextPutAll: '>'.
		s crtab; nextPutAll: '^APWikiPage'.
		s crtab: 2; nextPutAll: 'wiki: self'.
		s crtab: 2; nextPutAll: 'name: '; nextPutAll: aSymbol storeString.
		s crtab: 2; nextPutAll: 'text: '.
		s cr; nextPutAll: aString storeString.
	].

	self class compile: code classified: 'wikiPages'.
]

{ #category : #accessing }
TAPWiki classSide >> wikiEvaluationReceiver [
	^ self
]

{ #category : #accessing }
TAPWiki classSide >> wikiPageNamed: aSymbol [
	aSymbol = #Main
		ifTrue: [ ^ APWikiPage wiki: self name: #Main text: self comment ].
	^ self perform: (self methodSelectorForWikiPageNamed: aSymbol)
]
