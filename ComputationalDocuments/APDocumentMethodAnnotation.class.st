Class {
	#name : #APDocumentMethodAnnotation,
	#superclass : #GtMethodAnnotation,
	#category : #'ComputationalDocuments-GToolkit'
}

{ #category : #rendering }
APDocumentMethodAnnotation class >> tag [
	^ #documentMethod
]

{ #category : #'accessing - parameter values' }
APDocumentMethodAnnotation >> referencedMethod [
	<return: #RGMethodDefinition or: nil>
	^ referencedMethod ifNil: [ referencedMethod := self utility 
		valueOf: self constants nameParameterName
		in: self parameters 
		value: [ :aValue | self gtDocument storage methodDefinitionFromString: aValue ] 
		emptyValue: [ nil ] 
		defaultValue: [ nil ] ]
]
