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
			baseline: 'Roassal2' 
			with: [ spec repository: 'github://ObjectProfile/Roassal2:master/src' ].

		spec
			baseline: 'PolyMath'
			with: [ spec repository: 'github://PolyMathOrg/PolyMath:master/src' ].

		spec
			baseline: 'SingletonTrait'
			with: [ spec repository: 'github://khinsen/SingletonTrait:master' ].

		spec
			package: 'ComputationalDocuments' with: [ spec requires: #('DataFrame' 'Roassal2') ] ].
]
