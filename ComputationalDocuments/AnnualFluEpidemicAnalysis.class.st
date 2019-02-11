"
!The importance of flu epidemics in France since 1984

This analysis is based on ${class:name=FluDataset}$, a dataset on the incidence of influenza-like illness (French: syndrôme grippal) in France that has been made available by the ""Réseau Sentinelles"" (*https://www.sentiweb.fr/*). We use these weekly estimates to compute and compare the importance of flu epidemics from one year to another.

!!Results

A plot shows a small number of exceptionally high annual incidences.
[[[
AnnualFluEpidemicAnalysis uniqueInstance annualIncidencePlot canvas buildMorph.
]]]

A tabular view sorted by descending incidences makes it straightforward to identify the strongest epidemica:
[[[
AnnualFluEpidemicAnalysis uniqueInstance annualIncidence orderDescendingBy: 'annualIncidence'
]]]

It is also instructive to consider a histogram of the annual incidences, which are computed by
${method:name=AnnualFluEpidemicAnalysis>>#annualIncidence}$

[[[
AnnualFluEpidemicAnalysis uniqueInstance annualIncidenceHistogramPlot canvas buildMorph.
]]]
All these views show three exceptionally strong epidemics in the years 1986, 1989, and 1990, which implied about 10% of the French population.

!!Computation of the annual incidence

${class:name=FluDataset}$ provides weekly estimates for the incidence of influenza-like illness which show a strong peak in January and near-zero values in summer. We thus define the annual incidence in year Y as the sum over the weekly incidences from August 1st Y-1 to August 1st Y, with minor adjustments of the summation limits to adapt them to the weekly grid imposed by the data.

${method:name=AnnualFluEpidemicAnalysis>>#startOfSummationPeriodIn:|expanded=}$

We can compute the annual incidence only if we have the full data for a year, from August to August. This may not be the case for the first and last years in the dataset. Here is how we compute the list of years for which we can compute the annual incidence:
${method:name=AnnualFluEpidemicAnalysis>>#yearsWithCompleteData|expanded=}$

For extracting the weekly data records corresponding to our year definition, we use a method from ${class:name=FluDataset}$:
${method:name=FluDataset>>#asCleanedUpDataFrameForTimespan:|expanded=}$

Now we just have to tie all the pieces together and construct a new ${class:name=DataFrame}$ with the annual incidence data:
${method:name=AnnualFluEpidemicAnalysis>>#annualIncidence|expanded=}$

"
Class {
	#name : #AnnualFluEpidemicAnalysis,
	#superclass : #Object,
	#instVars : [
		'fluData',
		'annualIncidence'
	],
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #ComputationalDocuments
}

{ #category : #'instance creation' }
AnnualFluEpidemicAnalysis class >> new [
	self error: 'AnnualFluEpidemicAnalysis is a singleton -- send uniqueInstance instead'
]

{ #category : #'instance creation' }
AnnualFluEpidemicAnalysis class >> reset [
	<script>
	uniqueInstance := nil
]

{ #category : #'instance creation' }
AnnualFluEpidemicAnalysis class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := super new ]
]

{ #category : #accessing }
AnnualFluEpidemicAnalysis >> annualIncidence [
	| df |
	annualIncidence ifNotNil: [ ^ annualIncidence ].

	df := DataFrame fromRows:
			(self yearsWithCompleteData collect:
				[ :y |
					| ts data |
					ts := Timespan starting: (self startOfSummationPeriodIn: y - 1)
										duration: 1 year.
					data := fluData asCleanedUpDataFrameForTimespan: ts.
					{ y . (data column: 'inc') sum } ]).
	df columnNames: #('year' 'annualIncidence').
	annualIncidence := df.
	^ df
]

{ #category : #accessing }
AnnualFluEpidemicAnalysis >> annualIncidenceHistogram [
	| data histogram |
	data := self annualIncidence column: 'annualIncidence'.
	histogram := PMHistogram new.
	histogram setRangeFrom: data min to: data max bins: 10. 
	data do: [ :each | histogram accumulate: each ].
	^ histogram
]

{ #category : #plotting }
AnnualFluEpidemicAnalysis >> annualIncidenceHistogramPlot [
	| h hp minX b ds |
	h := self annualIncidenceHistogram.
	hp := h collectPoints: [ :each | each ].
	minX := hp first x.
	b := RTGrapher new.
	b extent: 300 @ 200.
	ds := RTData new.
	ds points: hp.
	ds x: [ :p |  p x - minX ].
	ds y: #y.
	ds connectColor: Color blue.
	ds noDot.
	b add: ds.
	b axisX
		labelConversion: [ :x | x + minX ].
	b axisY.
	b build.
	b view @ RTZoomableView @ RTZoomableBoxView.
	^ b view

]

{ #category : #plotting }
AnnualFluEpidemicAnalysis >> annualIncidencePlot [
	| df minYear b ds |
	df := self annualIncidence.
	minYear := (df column: 'year') first.
	b := RTGrapher new.
	b extent: 300 @ 200.
	ds := RTData new.
	ds interaction popup.
	ds points: df.
	ds x: [ :point | (point atKey: 'year') - minYear ].
	ds y: [ :point | point atKey: 'annualIncidence' ].
	ds barShape color: Color blue; width: 5.
	b add: ds.
	b axisX
		labelConversion: [ :x | x + minYear ].
	b axisY.
	b build.
	b view @ RTZoomableView @ RTZoomableBoxView.
	^ b view

]

{ #category : #inspecting }
AnnualFluEpidemicAnalysis >> gtInspectorIncidenceItemsIn: composite [
	<gtInspectorPresentationOrder: 0>
	composite table 
		title: 'Annual incidence';
		display: [ self annualIncidence ];
		column: 'Year' evaluated:
			[ :each | each atKey: 'year' ];
		column: 'Annual incidence estimate' evaluated:
			[ :each | each atKey: 'annualIncidence' ]
]

{ #category : #inspecting }
AnnualFluEpidemicAnalysis >> gtInspectorPlotHistogramIn: composite [
	<gtInspectorPresentationOrder: -10>
	composite roassal2
		title: 'Plot: histogram';
		initializeView: [ self annualIncidenceHistogramPlot ].

]

{ #category : #inspecting }
AnnualFluEpidemicAnalysis >> gtInspectorPlotIncidenceIn: composite [
	<gtInspectorPresentationOrder: -10>
	composite roassal2
		title: 'Plot: annual incidence';
		initializeView: [ self annualIncidencePlot ].

]

{ #category : #inspecting }
AnnualFluEpidemicAnalysis >> gtItemsFor: aView [
	<gtView>
	| aList |

	aList := aView columnedList
		title: 'Items' translated;
		priority: 50;
		items: [ self annualIncidence asOrderedCollection ].
		
	aList column
		title: 'Year';
		matchParent;
		item: [ :eachItem :eachIndex | eachItem atKey: 'year' ].
	
	aList column
		title: 'Estimated annual incidence';
		matchParent;
		item: [ :eachItem :eachIndex | eachItem atKey: 'annualIncidence' ].

	^ aList
]

{ #category : #initialization }
AnnualFluEpidemicAnalysis >> initialize [
	fluData := FluDataset uniqueInstance
]

{ #category : #accessing }
AnnualFluEpidemicAnalysis >> startOfSummationPeriodIn: aYear [
	^ Date year: aYear month: 8 day: 1
]

{ #category : #accessing }
AnnualFluEpidemicAnalysis >> yearsWithCompleteData [
	| weeks firstYear lastYear |
	weeks := fluData asCleanedUpDataFrame column: 'week'.
	firstYear := weeks first start year.
	weeks first start > (self startOfSummationPeriodIn: firstYear)
		ifTrue: [ firstYear := firstYear + 1 ].
	lastYear := weeks last end year.
	weeks last end < (self startOfSummationPeriodIn: lastYear)
		ifTrue: [ lastYear := lastYear - 1 ].
	^ (firstYear + 1) to: lastYear.

]
