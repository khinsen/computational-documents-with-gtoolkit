Extension { #name : #RTView }

{ #category : #'*ComputationalDocuments' }
RTView >> gtMorphFor: aView [
	<gtView>
	^ self canvas buildMorph gtMorphFor: aView
]
