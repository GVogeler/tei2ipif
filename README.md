# tei2ipif
experiments with a more or less generic proposal how to convert a TEI scholarly edition into an IPIF data set that can be process by http://github.com/IPIF/ipif-hub

# About
This is the start of a generic TEI2IPIF conversion based on some regular practice in modelling personography in TEI encoded scholarly editions.
It is based on the assumption that the edition uses the following tags to identify the occurence of a person in a text:
   `t:rs[@type="person"]`, `t:name[@type="person"]`, `t:persName`
that these tags identify the person by using either
    `@ref` or `@key`.
That the text referencing these persons is either referenced by
    `t:p`, `t:ab`, `t:item`, or `t:note`
That there might be a list persons in a 
    `t:listPerson`.
    
The current version uses the document htttp://gams.uni-graz.at/o:dipko:rb as are an example. The current state of the code (2023-09-03) contains several solutions based on this assumption (e.g. the identifier and URI for the source)
    
Comments and improvements are welcome!
    
Georg Vogeler <georg.vogeler@uni-graz.at>

# ToDo
- add listPerson/person handling
- check handling of `@key`
- check generalisation with other sample data
- create minimum test set for unit-testing:
	- sample input
	- fitting output
