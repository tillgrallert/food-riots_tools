---
title: "Workflow: food prices"
author: Till Grallert
date: 2018-01-31 22:49:01 +0200
tags:
- food prices
- r
- xslt
- workflow
---

This file briefly describes the workflow to:
1. mark-up food prices in transcriptions and excerpts using TEI; 
2. extract, normalise and convert price information to CSV;
3. plot the resulting dataset with R.

## 1. mark-up

I settled on the following TEI elements and attributes

1. `<measureGrp>`: grouping element to group more than one measure together and provide attributes that pertain to all of them.
2. at least two children `<measure>`, one of which must be of `@commodity="currency"`
    - for **prices**, I suggest using `@commodity="currency"`. 
        + The `@unit` then follows standard three-letter shorthand for currencies. 
            * Ottoman piasters shall be recorded as `@unit="ops"`
            * Ottoman beshlik coins are converted as Ps 2"20
            * Ottoman pound / lira (£T) shall be recorded as `@unit="ltq"`
        + the `@quantity` attribute has some restrictions as to its value and cannot contain the string 8-2-4 to signify, for instance, £ 8"2"4 or 8l 2s 4d. Yet it would be extremely tedious to encode all the fractions of non-metrical currencies as individual measures. I settled for on-the-spot conversion into decimal values, but this needs computing on the side of the encoder.
        + non metrical values can be recorded without `@quantity`
    - for **wages**, I suggest the same as for prices of commodities, but instead of, for instance, wheat, `@commodity="labor"` would be counted in `@unit="day"` or `@unit="month"`

    ~~~{.xml}
    Imagine, someone bought <measureGrp><measure commodity="wheat" quantity="2" unit="kile">two kile of wheat</measure> at the price of <measure commodity="currency" quantity="3" unit="ops">Ps 3</measure></measureGrp>.
    ~~~

    ~~~{.xml}
    <measureGrp>
        <measure commodity="wheat" unit="kile" quantity="1">kile  | wheat </measure> | 
        <measure commodity="currency" unit="ops" quantity="50">50</measure> | 
        <measure commodity="currency" unit="ops" quantity="56">56</measure>
    </measureGrp>
    ~~~

3. optionally `<measureGrp>` and `<measure>` elements denoting the price can be dated with the `@when` attribute. If all measures are dated to the same moment/period, the attributes go on the wrapping `<measureGrp>`

    ~~~{.xml}
    <tei:measureGrp when="1865-03-14">Yesterday, <tei:measure commodity="wheat" unit="kile" quantity="1">a kile of best wheat</tei:measure> was sold for <tei:measure commodity="currency" unit="ops" quantity="38">Ps 38</tei:measure> to <tei:measure commodity="currency" unit="ops" quantity="42">Ps 42</tei:measure></tei:measureGrp>
    ~~~


    ~~~{.xml}
    Last week <tei:measureGrp>the price for <tei:measure commodity="wheat" unit="kile" quantity="1">a kile of best wheat</tei:measure> rose from <tei:measure commodity="currency" unit="ops" quantity="38" when="1863-03-20">Ps 38</tei:measure> to <tei:measure commodity="currency" unit="ops" quantity="42" when="1863-03-25">Ps 42</tei:measure></tei:measureGrp>
    ~~~

4. Since non-metrical measures varied between places and since source can record prices from more than one location, the location can be specified with a custom `@location` attribute on `<measureGrp>` and `<measure>` elements denoting the price. If all measures relate to the same place, the attributes go on the wrapping `<measureGrp>`. `@location` accepts simple toponyms.

## 2. reference manager

All transcription and annotation of sources is done in Sente, which, albeit now discontinued, still runs without a glitch.

Data can be extracted from Sente using either the built in XML export or my custom workflow published [here](https://www.github.com/tillgrallert/lossless-sente-export). The direct export has some glitches and data must be cleaned / pre-processed using [custom XSLT](https://www.github.com/tillgrallert/tss_tools).

## 3. extract and normalize price data 

1. extract data
2. enrich every `<tei:measure>` with dates and locations based on information from ancestors `<tei:measureGrp>` and `<tss:reference>`
3. normalize non-metrical measures
4. regularize quantities to 1 

The XSLT stylesheet [`tei_retrieve-measures-as-csv.xsl`](xslt/tei_retrieve-measures-as-csv.xsl) can be run on any input XML. It will gather all `<measureGrp>` elements based on a number of selection criteria and outputs them as CSV sorted by date (either publication date of the source or the date recorded  `@when` attributes). With the help of [`tei-measure_normalize.xsl`](xslt/tei-measure_normalize.xsl) units are normalised as far as possible to allow for greater comparability across the dataset.

## 4. Plot prices with R