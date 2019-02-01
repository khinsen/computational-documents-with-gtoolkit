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
FluDataset >> asDataFrame [
	"Present the data as a DataFrame with columns converted to the most suitable data types:
	 numbers for numerical quantities, Timespans for the weeks. Missing values are represented
	 by nil."
	| data |
	data := self asRawDataFrame.
	"Transform the week specifications from pseudo-ISO8601 notation to Timespan objects"
	data column: 'week'
		  put: ((data column: 'week') collect:
					[ :each | Week year: (each first: 4) asNumber
										week: (each last: 2) asNumber ]).
	"Transform the numerical columns to numbers, replacing illegal values by nil"
	#('indicator' 'inc' 'inc_low' 'inc_up' 'inc100' 'inc100_low' 'inc100_up') do:
		[ :c |
			data column: c put: ((data column: c) collect:
				[ : each | [ each asNumber ] on: Error do: [ :exception | nil ] ]) ].
	"It would be nice to sort the data by the week column, but sorting is not implemented
	 for DataFrames."
	^ data

]

{ #category : #accessing }
FluDataset >> asRawDataFrame [
	"Present the data as a DataFrame but without any conversion. All values are Strings."
	| lines data |
	lines := rawData lines.
	data := DataFrame fromRows: ((lines allButFirst: 2) collect: [ :each | each splitOn: ',' ]).
	data columnNames: (lines second splitOn: ',').
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
