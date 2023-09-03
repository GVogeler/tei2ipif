<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    version="2.0">
    <!-- 
    
    This is the start of a generic TEI2IPIF conversion based on some regular practice in modelling personography in TEI encoded scholarly editions.
    It is based on the assumption that the edition uses the following tags to identify the occurence of a person in a text:
    t:rs[@type="person"], t:name[@type="person"], t:persName
    that these tags identify the person by using either
    @ref or @key
    That the text referencing these persons is either referenced by
    t:p, t:ab, t:item, or t:note
    That there might be a list persons in a 
    t:listPerson
    
    The current version uses the document htttp://gams.uni-graz.at/o:dipko:rb as are an example. The current state of the code (2023-09-03) contains several solutios based on this assumption (e.g. the identifier and URI for the source)
    
    Comments and improvements are welcome!
    
    Georg Vogeler <georg.vogeler@uni-graz.at>
    -->
    <xsl:output method="text"/>
    <xsl:variable name="pid" select="//t:idno[@type='PID']/replace(.,'\W', '_')"/>
    <xsl:variable name="createdBy" select="//t:titleStmt/string-join((if(t:editor) then (t:editor) else (t:author)|t:respStmt/t:persName)/normalize-space(),', ')"/>
        <!-- Alternative factoid-Erzeuger? -->
    <xsl:template match="/">
        <!-- The file itself as a factoid
                consisting of the pointer to the person in rs[@type="person"]/@ref, 
                    the current document as source (incl. an internal chunk identifier?,
                    the text of the current chunk a generic statement and
                    the reference itself as a name statement?
        -->
        
{"factoids": [
        <xsl:apply-templates select="//t:text//(t:rs[@type='person']|t:persName)[@ref]" mode="factoids"/>],
        "persons": [<xsl:apply-templates select="//t:text//(t:rs[@type='person']|t:persName)[@ref][not(ancestor::t:listPerson)]" mode="persons"/>
        <xsl:apply-templates select="//t:listPerson/t:person" mode="persons"/>
        <xsl:text>],
    "sources": [{
            "@id": "s_</xsl:text><xsl:value-of select="$pid"/><xsl:text>",
            "label": "</xsl:text><xsl:value-of select="/t:TEI/t:teiHeader/t:fileStmt/t:title"/><xsl:text>",
            "uris": ["https://gams.uni-graz.at/</xsl:text><xsl:value-of select="//t:idno[@type='PID']"/><xsl:text>"],
            "createdBy": "</xsl:text><xsl:value-of select="$createdBy"/><xsl:text>",
            "createdWhen": "</xsl:text><xsl:value-of select="current-dateTime()"/><xsl:text>"</xsl:text>
            <!--,"modifiedBy": "Researcher7",
            "modifiedWhen": "2012-04-23"-->
        }

    ],
    "statements": [<xsl:apply-templates select="//t:text//(t:rs[@type='person']|t:persName)[@ref]" mode="statement"/>]
} 
    </xsl:template>
    <xsl:template match="//t:text//(t:rs[@type='person']|t:persName)[@ref]" mode="factoids">
        <xsl:variable name="ref" select="@ref"/>
        <xsl:text>{
            "@id": "f_</xsl:text><xsl:call-template name="personID"/><xsl:text>_</xsl:text><xsl:value-of select="generate-id()"/><xsl:text>",
            "person-ref": { "@id": "p_</xsl:text><xsl:call-template name="personID"/><xsl:text>" },
            "source-ref": { "@id": "s_</xsl:text><xsl:value-of select="$pid"/><xsl:text>" },
            "statement-refs": [</xsl:text><xsl:apply-templates select="." mode="listStatementIDs"/><xsl:text>],
            "createdBy": "</xsl:text><xsl:value-of select="$createdBy"/><xsl:text>",
            "createdWhen": "</xsl:text><xsl:value-of select="current-dateTime()"/><xsl:text>"
            </xsl:text><!--,"modifiedBy": "Researcher2",
            "modifiedWhen": "2012-04-23"-->
        }
        <xsl:if test="following::t:rs|following::t:persName"><xsl:text>,</xsl:text></xsl:if>
    </xsl:template>
    <xsl:template match="t:text//(t:rs[@type='person']|t:persName)[@ref]" mode="listStatementIDs">
        <!-- ToDo -->
        <!-- 1. Content of the element itself -->
        <xsl:text>{ "@id": "st_</xsl:text><xsl:value-of select="if(@xml:id) then (@xml:id) else (generate-id())"/><xsl:text>" }</xsl:text>
        <!-- 2. Context of the element:  -->
        <xsl:variable name="context" select="(ancestor::t:p|ancestor::t:ab|ancestor::t:item|ancestor::t:note)[1]"/>
        <xsl:if test="$context"><xsl:text>,{ "@id": "st_</xsl:text><xsl:value-of select="
            if($context/@xml:id) then ($context/@xml:id) else
            ($context/generate-id())"/><xsl:text>" }</xsl:text>
        </xsl:if>
<!--        <xsl:if test="(following::t:rs|following::t:persName"><xsl:text>,</xsl:text></xsl:if>
-->    </xsl:template>
    <!-- Persons -->
    <xsl:template match="//t:text//(t:rs[@type='person']|t:persName)[@ref]" mode="persons">
        <xsl:text>{
            "@id": "</xsl:text><xsl:call-template name="personID"/><xsl:text>",
        "label": "</xsl:text><xsl:value-of select="normalize-space()"/><xsl:text>",
        "uris": ["http://ahpiss.com/Person1", "http://gnd.de/Person1", "http://shouldbethere.com"],
        "createdBy": "</xsl:text><xsl:value-of select="$createdBy"/><xsl:text>",
        "createdWhen": "</xsl:text><xsl:value-of select="current-dateTime()"/><xsl:text>"</xsl:text>
        <!--,"modifiedBy": "Researcher3",
        "modifiedWhen": "2012-04-23"-->
        }
        <xsl:if test="(following::t:rs[@type='person']|following::t:persName)[@ref]"><xsl:text>,</xsl:text></xsl:if>
    </xsl:template>
    <!-- Statements -->
    <xsl:template match="//t:text//(t:rs[@type='person']|t:persName)[@ref]" mode="statement">
        <xsl:variable name="context" select="(ancestor::t:p|ancestor::t:ab|ancestor::t:item|ancestor::t:note)[1]"/>
        <!-- ToDo -->
        {
        "@id": "st_<xsl:value-of select="if(@xml:id) then (@xml:id) else (generate-id())"/>",
        "createdBy": "<xsl:value-of select="$createdBy"/>",
        "createdWhen": "<xsl:value-of select="current-dateTime()"/>",
        <!--"modifiedBy": "RHadden",
        "modifiedWhen": "2022-03-25",-->
        "label": "",
        "statementType": {
            "uri": "http://xmlns.com/foaf/0.1/#term_name",
            "label": "name - A name for some thing"
        },
        "name": "<xsl:value-of select="normalize-space()"/>"
        },
        {
        "@id": "st_<xsl:value-of select="if($context/@xml:id) then ($context/@xml:id) else ($context/generate-id())"/>",
<!--        "places": [{ "uri": "http://places.com/Germany", "label": "Germany" }],-->
        "createdBy": "<xsl:value-of select="$createdBy"/>",
        "createdWhen": "<xsl:value-of select="current-dateTime()"/>",
        <!--"modifiedBy": "RHadden",
        "modifiedWhen": "2022-03-25",-->
        "label": "",
        "statementText": "<xsl:value-of select="$context/normalize-space()"/>"
        }
        <xsl:if test="following::t:rs|following::t:persName"><xsl:text>,</xsl:text></xsl:if>
    </xsl:template>
    
    <!-- Bilden der Personen-ID -->
    <xsl:template name="personID">
        <xsl:value-of select="(self::t:rs[@type='person']/replace(@ref,'^#',''),
            self::t:persName/replace(@ref,'^#','')
            ,self::t:person/@xml:id)"/>
    </xsl:template>
    
    <!-- ToDo: Strukturierte Personenangaben aus listPerson -->
    <xsl:template match="t:listPerson/t:person" mode="person">
        { "@id": "",
          "label": "",
          "uris": [<xsl:apply-templates select="t:idno[@type='URI']"/>],
          "createdBy": "Researcher3",
          "createdWhen": "2012-04-23",
          "modifiedBy": "Researcher3",
          "modifiedWhen": "2012-04-23"
        }
        <xsl:if test="following-sibling::t:person"><xsl:text>,</xsl:text></xsl:if>
    </xsl:template>
    <xsl:template match="t:person/t:idno[@type='URI']">"uri" : "<xsl:value-of select="."/>"
        <xsl:if test="following-sibling::t:idno[@type='URI']"><xsl:text>,</xsl:text></xsl:if>
    </xsl:template>
    <xsl:template match="t:listPerson/t:person" mode="statements">
        <xsl:apply-templates/>
    </xsl:template>
</xsl:stylesheet>