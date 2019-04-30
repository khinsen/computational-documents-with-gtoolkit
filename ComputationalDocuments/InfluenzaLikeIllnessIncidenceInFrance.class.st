"
!Incidence of influenza-like illness in France

This dataset on the incidence of influenza-like illness (French: syndrôme grippal) in France has been made available by the ""Réseau Sentinelles"" (*https://www.sentiweb.fr/*) and provides estimates extrapolated from the diagnoses made by general practitioners all over the country. The dataset contains cumulative weekly data, starting in October 1984. Unfortunately, the Web site does not provide the raw data (number of diagnoses), nor an explanation of the statistical methods used for generating the estimates.

For each week, an  incidence estimation is provided together with a 95% confidence interval. A population-relative incidence estimatation (cases per 100.000 inhabitants) is provided as well, again with a 95% confidence interval. The Web site does not say where the population data has been taken from.

See ${wikiPage:name=DataProcessing}$ for an explanation of how the datasets in this document were obtained from the downloaded tables.

Here is a tabular view of the data:
[[[
self data.
]]]

And here are the descriptions of the fields provided by the Web site:
[[[
self fieldDescriptions
]]]

One week in the dataset has missing data:
[[[
self data select:
	[ :row | row detect: #isNil
					 ifFound: [ true ]
					 ifNone: [ false ]]
]]]

A plot of the whole time series for the absolute incidence gives a good overview:
[[[
self  absoluteIncidencePlot.
]]]

A zoom on a few years makes the seasonal character of the incidence clearer:
[[[
(FluDataset uniqueInstance incidencePlotForTimespan: (Timespan starting: (DateAndTime fromString: '2014-01-01') duration: 4 years))
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
	#name : #InfluenzaLikeIllnessIncidenceInFrance,
	#superclass : #APActivePaper,
	#instVars : [
		'#downloadUrl => APDataSlot',
		'#csvFile => APDataSlot',
		'#textData => APDataSlot',
		'#data => APDataSlot',
		'#fieldDescriptions => APDataSlot'
	],
	#category : #ComputationalDocuments
}

{ #category : #testing }
InfluenzaLikeIllnessIncidenceInFrance class >> isAbstract [ ^ false
]

{ #category : #wikiPages }
InfluenzaLikeIllnessIncidenceInFrance class >> wikiPageDataProcessing [
	"This method was automatically generated."
	<wikiPage: #DataProcessing>
	^APWikiPage
		wiki: self
		name: #DataProcessing
		text: 
'!Data processing steps

1. Set the URL for downloading the data
${method:name=InfluenzaLikeIllnessIncidenceInFrance>>#setDownloadUrl|expanded=}$

2. Download the CSV file into a string
${method:name=InfluenzaLikeIllnessIncidenceInFrance>>#downloadCsvFile|expanded=}$

3. Parse the CSV data into a ${class:name=DataFrame}$
${method:name=InfluenzaLikeIllnessIncidenceInFrance>>#parseCsvFile|expanded=}$

4. Convert each column to an appropriate data type
${method:name=InfluenzaLikeIllnessIncidenceInFrance>>#convertDataTypes|expanded=}$





'
]

{ #category : #'data conversion' }
InfluenzaLikeIllnessIncidenceInFrance >> convertColumnToNumbers: aColumn [
	^ aColumn collect:
		[ : each |
			[ each asNumber ]
			on: Error do: [ :exception | nil ] ]
]

{ #category : #scripts }
InfluenzaLikeIllnessIncidenceInFrance >> convertDataTypes [
	<computes: #data>
	| columnNames |

	"Make a new data frame of equal dimensions and column names."
	columnNames := textData columnNames.
	data := DataFrame new: textData dimensions.
	data columnNames: columnNames.
	columnNames := columnNames copy.

	"Transform week column into Week objects."
	data column: 'week'
		  put: ((textData column: 'week') collect:
					[ :each | Week year: (each first: 4) asNumber
										isoWeek: (each last: 2) asNumber ]).
	columnNames remove: 'week'.

	"Transform numerical columns into numbers, keep text columns as text"
	columnNames do:
		[ :cn |
			| column type |
			column := textData column: cn.
			type := (fieldDescriptions at: cn) at: 'type'.
			type = 'integer'
				ifTrue: [ column := self convertColumnToNumbers: column ].
			data column: cn put: column ].

	"Sort by ascending week number."
	data sortBy: 'week'.
	
	"Check that all data was converted."
	self assert: data dimensions = textData dimensions.
]

{ #category : #generated }
InfluenzaLikeIllnessIncidenceInFrance >> csvFile [ self ensureDataset: #csvFile. ^ csvFile
]

{ #category : #generated }
InfluenzaLikeIllnessIncidenceInFrance >> data [ self ensureDataset: #data. ^ data
]

{ #category : #scripts }
InfluenzaLikeIllnessIncidenceInFrance >> downloadCsvFile [
	<computes: #csvFile>
	| dataFile |
	dataFile :=
		ZnClient new
			beOneShot;
			get: downloadUrl;
			entity.
	csvFile := dataFile contents
]

{ #category : #scripts }
InfluenzaLikeIllnessIncidenceInFrance >> downloadFieldDescriptions [
	<computes: #fieldDescriptions>
	| schemaUrl schemaJson schema |
	schemaUrl := 'https://ns.sentiweb.fr/incidence/csv-schema-v1.json'.
	schemaJson :=
			ZnClient new
				beOneShot;
				get: schemaUrl;
				entity.
	schema := STONJSON fromString: schemaJson contents.
	fieldDescriptions := Dictionary new.
	((schema at: 'schema') at: 'fields') do:
		[ :field |
			fieldDescriptions at: (field at: 'name') put: field ].

]

{ #category : #generated }
InfluenzaLikeIllnessIncidenceInFrance >> downloadUrl [ self ensureDataset: #downloadUrl. ^ downloadUrl
]

{ #category : #generated }
InfluenzaLikeIllnessIncidenceInFrance >> fieldDescriptions [ self ensureDataset: #fieldDescriptions. ^ fieldDescriptions
]

{ #category : #initialization }
InfluenzaLikeIllnessIncidenceInFrance >> initialize [
	super initialize.
	self class initializeSlots: self.
]

{ #category : #scripts }
InfluenzaLikeIllnessIncidenceInFrance >> parseCsvFile [
	<computes: #textData>
	| csvLines dataLines |
	csvLines := csvFile lines.
	dataLines := csvLines allButFirst: 2.
	textData := DataFrame withRows:
		(dataLines collect: [ :each | each splitOn: ',' ]).
	textData columnNames:
		((csvLines at: 2) splitOn: ',')

]

{ #category : #scripts }
InfluenzaLikeIllnessIncidenceInFrance >> setDownloadUrl [
	<computes: #downloadUrl>
	downloadUrl := 'http://www.sentiweb.fr/datasets/incidence-PAY-3.csv'
]

{ #category : #generated }
InfluenzaLikeIllnessIncidenceInFrance >> textData [ self ensureDataset: #textData. ^ textData
]
