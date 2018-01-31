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

1. `<measureGrp>`
2. at least two children `<measure>`, one of which must be of `@commodity="currency"`
    - for **prices**, I suggest using `@commodity="currency"`. 
        + The `@unit` then follows standard three-letter shorthand for currencies. 
            * Ottoman piasters shall be recorded as `@unit="ops"`
            * Ottoman beshlik coins are converted as Ps 2"20
            * Ottoman pound / lira (£T) shall be recorded as `@unit="ltq"`
        + the `@quantity` attribute has some restrictions as to its value and cannot contain the string 8-2-4 to signify, for instance, £ 8"2"4 or 8l 2s 4d. Yet it would be extremely tedious to encode all the fractions of non-metrical currencies as individual measures. I settled for on-the-spot conversion into decimal values, but this needs computing on the side of the encoder.
        + non metrical values can be recorded without `@quantity`
    - for **wages**, I suggest the same as for prices of commodities, but instead of, for instance, wheat, `@commodity="labor"` would be counted in `@unit="day"` or `@unit="month"`
3. optionally `<measure>` elements can be dated with the `@when` attribute

~~~{.xml}
Imagine, someone bought <measureGrp><measure commodity="wheat" quantity="2" unit="kile">two kile of wheat</measure> at the price of <measure commodity="currency" quantity="3" unit="ops">Ps 3</measure></measureGrp>.
~~~

~~~{.xml}
<measureGrp>
    <measure commodity="wheat" unit="kile" quantity="1">kile  | wheat </measure> | <measure commodity="currency" unit="ops" quantity="50">50</measure> | <measure commodity="currency" unit="ops" quantity="56">56</measure>
</measureGrp>
~~~

## 2. reference manager

All transcription and annotation of sources is done in Sente, which, albeit now discontinued, still runs without a glitch.

Data can be extracted from Sente using either the built in XML export or my custom workflow published [here](). The direct export has some glitches and data must be cleaned / pre-processed using [custom XSLT]().

## 3. extract and normalize price data 

The XSLT stylesheet [`tei_retrieve-measures-as-csv.xsl`](xslt/tei_retrieve-measures-as-csv.xsl) can be run on any input XML. It will gather all `<measureGrp>` elements based on a number of selection criteria and outputs them as CSV sorted by date (either publication date of the source or the date recorded  `@when` attributes). With the help of [`tei-measure_normalize.xsl`](xslt/tei-measure_normalize.xsl) units are normalised as far as possible to allow for greater comparability across the dataset.

## 4. Plot prices with R