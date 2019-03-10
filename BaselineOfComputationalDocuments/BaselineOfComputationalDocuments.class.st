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
			baseline: 'ObservableSlot'
			with: [ spec repository: 'github://guillep/ObservableSlots:master/src' ].

		spec
			package: 'ComputationalDocuments' ].
]
