"
!Incidence of influenza-like illness in France

This dataset on the incidence of influenza-like illness (French: syndrôme grippal) in France has been made available by the ""Réseau Sentinelles"" (*https://www.sentiweb.fr/*) and is based on the observations by general practitioners all over the country. The dataset contains cumulative weekly data, starting in 1984:
[[[
(FluDataset uniqueInstance asDataFrame column: 'week') first start asDate
]]]

For each week, an estimated incidence is provided together with statistical lower and upper bounds for this estimate.
[[[
FluDataset uniqueInstance.
]]]

!!Data processing

The raw data is downloaded directly from the Web site, noting the retrieval date because the URL points to a continuously updated file.
${method:name=FluDataset>>#initialize|expanded=}$

Next, the downloaded CSV file is parsed and the data fields, still in text format, are loaded into a ${class:name=DataFrame}$.
${method:name=FluDataset>>#asRawDataFrame|expanded=}$

A proper ${class:name=DataFrame}$ is then constructed by converting each column into an appropriate data type. Most columns are numerical, the most notable exception being 'week', which indicates the week to which the observations belong, and which are converted to ${class:name=Week}$ objects. In the numerical columns, failed conversions indicate missing data that gets replaced by ==nil==. To facilitate the identification of rows with missing data values, a new boolean column 'missingData' is added.
${method:name=FluDataset>>#asDataFrame|expanded=}$

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
	 numbers for numerical quantities, Timespans for the weeks. The rows are sorted by
	 increasing date. Missing values are represented by nil. A boolean-valued column 'missingData'
	 facilitates finding incomplete rows."
	| data missingData |
	data := self asRawDataFrame.
	"Transform the week specifications from pseudo-ISO8601 notation to Timespan objects.
	 Sort by week."
	data column: 'week'
		  put: ((data column: 'week') collect:
					[ :each | Week year: (each first: 4) asNumber
										week: (each last: 2) asNumber ]).
	data orderBy: 'week'.
	"Transform the numerical columns to numbers, replacing illegal values by nil"
	#('indicator' 'inc' 'inc_low' 'inc_up' 'inc100' 'inc100_low' 'inc100_up') do:
		[ :c | data toColumn: c
						applyElementwise:
							[ : each | [ each asNumber ]
											 on: Error do: [ :exception | nil ] ] ].
	"Add a column with a missing data indicator."
	missingData := Array new: data size.
	data collect: [ :row | row detect: [ :each | each isNil ]
										ifFound: [ true ]
										ifNone: [ false ]]
		  into: missingData.
	data atColumn: 'missingData' put: missingData.
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

{ #category : #inspecting }
FluDataset >> gtItemsFor: aView [
	<gtView>
	| aList |

	aList := aView columnedList
		title: 'Items' translated;
		priority: 50;
		items: [ self asDataFrame asOrderedCollection ].
		
	aList column
		title: 'Week starting';
		matchParent;
		item: [ :eachItem :eachIndex | (eachItem atKey: 'week') start asDate ].
	
	aList column
		title: 'Estimated incidence';
		matchParent;
		item: [ :eachItem :eachIndex | eachItem atKey: 'inc' ].

	aList column
		title: 'Lower/upper bound (95%)';
		matchParent;
		item: [ :eachItem :eachIndex | { eachItem atKey: 'inc_low' . eachItem atKey: 'inc_up' }];
		itemFormat: [ :item | item first asString , ' / ' , item second asString ].
	
	^ aList
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
