"
!Incidence of influenza-like illness in France

This dataset on the incidence of influenza-like illness (French: syndrôme grippal) in France has been made available by the ""Réseau Sentinelles"" (*https://www.sentiweb.fr/*) and provides estimates extrapolated from the diagnoses made by general practitioners all over the country. The dataset contains cumulative weekly data, starting in October 1984. Unfortunately, the Web site does not provide the raw data (number of diagnoses), nor an explanation of the statistical methods used for generating the estimates.

For each week, an estimated incidence is provided together with statistical lower and upper bounds for this estimate. A population-relative incidence estimate (cases per 100.000 inhabitants) is provided as well. The Web site does not say where the population data has been taken from.

Here is a tabular view of the data:
[[[
FluDataset uniqueInstance.
]]]

For a plot, run the following code:
[[[
FluDataset uniqueInstance plotIncidence inspect.
]]]

The dataset has missing incidence data for one week: 
[[[
(FluDataset uniqueInstance asDataFrame select: [ :row | row atKey: 'missingData' ]) column: 'week'
]]]

Searching for gaps (week-to-week distances of more than seven days) in the week column after removing the missing data point yields exactly one gap corresponding to the missing data point, meaning that the dataset is otherwise complete:
[[[
| weeks gaps |
weeks := FluDataset uniqueInstance asCleanedUpDataFrame column: 'week'.
gaps := OrderedCollection new.
weeks allButFirst with: weeks allButLast do:
	[ :w2 :w1 |
		(w2 - w1) = (Duration days: 7)
			ifFalse: [ gaps add: { w1 . w2 } ] ].
gaps
]]]

 
!!Data processing

The raw data is downloaded directly from the Web site, noting the retrieval date because the URL points to a continuously updated file.
${method:name=FluDataset>>#initialize|expanded=}$

Next, the downloaded CSV file is parsed and the data fields, still in text format, are loaded into a ${class:name=DataFrame}$.
${method:name=FluDataset>>#asRawDataFrame|expanded=}$

A proper ${class:name=DataFrame}$ is then constructed by converting each column into an appropriate data type. Most columns are numerical, the most notable exception being 'week', which indicates the week to which the observations belong, and which are converted to ${class:name=Week}$ objects. In the numerical columns, failed conversions indicate missing data that gets replaced by ==nil==. To facilitate the identification of rows with missing data values, a new boolean column 'missingData' is added.
${method:name=FluDataset>>#asDataFrame|expanded=}$

Finally, a cleaned-up ${class:name=DataFrame}$ contains neither the rows with missing data nor the uninteresting columns whose values are constant.
${method:name=FluDataset>>#asCleanedUpDataFrame|expanded=}$

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
FluDataset >> asCleanedUpDataFrame [
	"Answer a DataFrame with only the most useful data. Rows with missing data are removed,
	 and only the most informative columns are retained: 'inc', 'inc_low', 'inc_up', 
	 the population-relative versions 'inc100', 'inc100_low', and 'inc100_up', and 'weeks'."

	| data |
	data := self asDataFrame.
	"Note: there is no reject: method in class DataFrame."
	^ (data select: [ :row | (row atKey: 'missingData') not ])
		columns: #('week' 'inc' 'inc_low' 'inc_up' 'inc100' 'inc100_low' 'inc100_up')
]

{ #category : #accessing }
FluDataset >> asDataFrame [
	"Present the data as a DataFrame with columns converted to the most suitable data types:
	 numbers for numerical quantities, Timespans for the weeks. The rows are sorted by
	 increasing date. Missing values are represented by nil. A boolean-valued column 'missingData'
	 facilitates finding incomplete rows."
	| data missingData |
	data := self asRawDataFrame.
	"Transform the week specifications from pseudo-ISO8601 notation to Week objects.
	 Sort by week."
	data column: 'week'
		  put: ((data column: 'week') collect:
					[ :each | Week year: (each first: 4) asNumber
										isoWeek: (each last: 2) asNumber ]).
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
FluDataset >> gtInspectorIncidenceItemsIn: composite [
	<gtInspectorPresentationOrder: 0>
	composite table 
		title: 'Incidence';
		display: [ self asDataFrame ];
		column: 'Week starting' evaluated:
			[ :each | (each atKey: 'week') start asDate ];
		column: 'Incidence' evaluated:
			[ :each | each atKey: 'inc' ];
		column: 'Lower/Upper bound (95%)' evaluated:
			[ :each | (each atKey: 'inc_low') asString , ' - ' , (each atKey: 'inc_up') asString ]
]

{ #category : #inspecting }
FluDataset >> gtInspectorPlotDataIn: composite [
	<gtInspectorPresentationOrder: -10>
	composite roassal2
		title: 'Plot';
		initializeView: [ self plotIncidence ].

]

{ #category : #inspecting }
FluDataset >> gtInspectorPopulationRelativeIncidenceItemsIn: composite [
	<gtInspectorPresentationOrder: 0>
	composite table 
		title: 'Incidence per 100 inhabitants';
		display: [ self asDataFrame ];
		column: 'Week starting' evaluated:
			[ :each | (each atKey: 'week') start asDate ];
		column: 'Incidence per 100 inhabitants' evaluated:
			[ :each | each atKey: 'inc100' ];
		column: 'Lower/Upper bound (95%)' evaluated:
			[ :each | (each atKey: 'inc100_low') asString , ' - ' , (each atKey: 'inc100_up') asString ]
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

{ #category : #plotting }
FluDataset >> plotIncidence [
	| df minDate b ds |
	df := self asCleanedUpDataFrame.
	minDate := ((df at: 1) atKey: 'week') start asDate.
	b := RTGrapher new.
	b extent: 300 @ 200.
	ds := RTData new.
	ds interaction popup.
	ds points: (df columns: #('week' 'inc')).
	ds x: [ :point | ((point at: 1) start asDate julianDayNumber) - minDate julianDayNumber ].
	ds y: [ :point | point at: 2 ].
	ds barShape color: Color blue; width: 1.
	b add: ds.
	b axisX
		labelRotation: -40;
		labelConversion: [ :v | Date julianDayNumber: v + minDate julianDayNumber ].
	b axisY.
	b build.
	b view @ RTZoomableView @ RTZoomableBoxView.
	^ b view

]

{ #category : #accessing }
FluDataset >> rawData [
	^rawData

]
