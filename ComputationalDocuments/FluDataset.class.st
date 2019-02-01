"
[[[
| graph |
graph := #(5 6 5 6 4 2 10 10 10 10 12 12 14 8 5 6 4 2 3 4 5 6) histogram.
graph view canvas open
]]]
"
Class {
	#name : #FluDataset,
	#superclass : #Object,
	#instVars : [
		'rawData',
		'retrievalTime'
	],
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #ComputationalDocuments
}

{ #category : #'instance creation' }
FluDataset class >> new [
	self error: 'Author is a singleton -- send uniqueInstance instead'
]

{ #category : #'instance creation' }
FluDataset class >> reset [
	<script>
	^ self uniqueInstance reset.
]

{ #category : #'instance creation' }
FluDataset class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := super new ]
]

{ #category : #accessing }
FluDataset >> asInterpretedDataFrame [
	| data |
	data := self asRawDataFrame.
	data column: 'week'
		  put: ((data column: 'week') collect:
					[ :each | Week year: (each first: 4) asNumber week: (each last: 2) asNumber ]).
	#('inc' 'inc_low' 'inc_up' 'inc100' 'inc100_low' 'inc100_up') do:
		[ :c | data column: c put: ((data column: c) collect: #asNumber) ].
	^ data

]

{ #category : #accessing }
FluDataset >> asRawDataFrame [
	| lines data |
	lines := rawData lines.
	data := DataFrame fromRows: ((lines allButFirst: 2) collect: [ :each | each splitOn: ',' ]).
	data columnNames: (lines second splitOn: ',').
	^ data

]

{ #category : #accessing }
FluDataset >> extractColumns: names [
	| lines  columnNames indices data |
	lines := rawData lines.
	columnNames := lines second splitOn: ','.
	indices := names collect: [ :each | columnNames indexOf: each ].
	data := Array2D rows: lines size - 2 columns: names size.
	(lines allButFirst: 2) withIndexDo:
		[ :line :i |
			| values |
			values := line splitOn: ','.
			indices withIndexDo: [ :j :jj | data at: i at: jj put: (values at: j) ] ].
	^ data
]

{ #category : #initialization }
FluDataset >> initialize [
	rawData := 'http://www.sentiweb.fr/datasets/incidence-PAY-3.csv' asZnUrl retrieveContents.
	retrievalTime := DateAndTime now.
]

{ #category : #accessing }
FluDataset >> rawData [
	^rawData

]
