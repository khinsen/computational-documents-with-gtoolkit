Class {
	#name : #APWikiTest,
	#superclass : #TestCase,
	#instVars : [
		'wiki'
	],
	#category : #'ComputationalDocuments-Tests'
}

{ #category : #running }
APWikiTest >> setUp [
	wiki := Object subclass: #APWikiTestExample
						uses: TAPWiki
						instanceVariableNames: ''
						classVariableNames: ''
						package: TAPWiki package name.
]

{ #category : #running }
APWikiTest >> tearDown [
	wiki removeFromSystem
]

{ #category : #testing }
APWikiTest >> testMethodSelector [
	self assert: (wiki methodSelectorForWikiPageNamed: #foo) equals: #wikiPageFoo.

]

{ #category : #testing }
APWikiTest >> testPageCreation [
	wiki store: '!!Page Foo' inWikiPageNamed: #foo.
	wiki wikiPageNamed: #foo.
]
