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
			baseline: 'ActivePapers'
			with: [ spec repository: 'github://activepapers/activepapers-pharo/src' ].

		spec
			baseline: 'DataFrame'
			with: [ spec repository: 'github://PolyMathOrg/DataFrame/src' ].

		spec
			baseline: 'Roassal2' 
			with: [ spec repository: 'github://ObjectProfile/Roassal2/src' ].

		spec
			baseline: 'PolyMath'
			with: [ spec repository: 'github://PolyMathOrg/PolyMath/src' ].

		spec
			baseline: 'SingletonTrait'
			with: [ spec repository: 'github://khinsen/SingletonTrait' ].

		spec
			baseline: 'EqualityThroughVariablesTrait' 
			with: [ spec repository: 'github://khinsen/EqualityThroughVariablesTrait/src' ].

		spec
			package: 'ComputationalDocuments'
			with: [ spec requires: #('ActivePapers' 'DataFrame' 'Roassal2' 'PolyMath'
											'SingletonTrait' 'EqualityThroughVariablesTrait') ] ].
]
