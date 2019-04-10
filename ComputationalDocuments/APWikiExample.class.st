"
!!A demo Wiki

There is this page plus the ${wikiPage:name=Other}$ page.

The ${wikiPage:name=Missing}$ page does not exist.
"
Class {
	#name : #APWikiExample,
	#superclass : #Object,
	#traits : 'TAPWiki',
	#classTraits : 'TAPWiki classTrait',
	#category : #'ComputationalDocuments-Demo'
}

{ #category : #wikiPages }
APWikiExample class >> wikiPageOther [
	"This method was automatically generated."
	<wikiPage: #Other>
	^APWikiPage
		wiki: self
		name: #Other
		text: 
'!!The other page'
]
