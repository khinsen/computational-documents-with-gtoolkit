"
!A simple ActivePaper

It contains two datasets,

[[[

self x

]]]

and

[[[
self y
]]]

"
Class {
	#name : #APActivePaperExample,
	#superclass : #APActivePaper,
	#instVars : [
		'#x => APDataSlot',
		'#y => APDataSlot'
	],
	#category : #ComputationalDocuments
}

{ #category : #initialization }
APActivePaperExample >> computeY [
	<computes: #y>
	y := x / 2
]

{ #category : #initialization }
APActivePaperExample >> initialize [
	super initialize.
	self class initializeSlots: self.
]

{ #category : #initialization }
APActivePaperExample >> setX [
	<computes: #x>
	x := 42
]

{ #category : #generated }
APActivePaperExample >> x [ self apCompute: #x. ^ x
]

{ #category : #generated }
APActivePaperExample >> y [ self apCompute: #y. ^ y
]
