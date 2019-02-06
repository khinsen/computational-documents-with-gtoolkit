Class {
	#name : #BaselineOfComputationalDocuments,
	#superclass : #BaselineOf,
	#category : #BaselineOfComputationalDocuments
}

{ #category : #baselines }
BaselineOfComputationalDocuments >> baseline: spec [
	<baseline>
	spec for: #common do: [			

		spec
			baseline: 'DataFrame'
			with: [ spec repository: 'github://PolyMathOrg/DataFrame:master/src' ].

		spec
			package: 'ComputationalDocuments' with: [ spec requires: #('DataFrame') ] ].
]
