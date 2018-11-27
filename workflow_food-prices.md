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

There are two types of price information to be found in our sources: 

1. quantitative information on the ratio of two commodities, one of which is a currency;
2. qualitative information, such as "rising prices", "high prices", "falling prices", and "low prices" (etc.)

# quantitative price information
## 1. mark-up

I settled on the following TEI elements and attributes

1. `<measureGrp>`: grouping element to group more than one measure together and provide attributes that pertain to all of them.
2. at least two children `<measure>`, one of which must be of `@commodity="currency"`
    - for **prices**, I suggest using `@commodity="currency"`. 
        + The `@unit` then follows standard three-letter shorthand for currencies. 
            * Ottoman piasters shall be recorded as `@unit="ops"`
            * Ottoman beshlik coins are converted as Ps 2"20
            * Ottoman pound / lira (£T) shall be recorded as `@unit="ltq"`[^1]
        + the `@quantity` attribute has some restrictions as to its value and cannot contain the string 8-2-4 to signify, for instance, £ 8"2"4 or 8l 2s 4d. Yet it would be extremely tedious to encode all the fractions of non-metrical currencies as individual measures. I settled for on-the-spot conversion into decimal values, but this needs computing on the side of the encoder.
        + non metrical values can be recorded without `@quantity`
        - to differentiate **taxes** from **prices**, the wrapping `<measureGrp>` must carry an `@type="tax"` attribute.
        - to differentiate **observed prices** from those **set by the authorities**, the wrapping `<measureGrp>` must carry an `@type="official"` attribute.
        - to differentiate **acute prices** from **average prices**, the wrapping `<measureGrp>` carries an `@type="average"` attribute in the latter case.
        - [*NOTE*]: There is a difference between abstract currencies (for lack of a better word) and concrete denominations. 
    - for **wages**, I suggest the same as for prices of commodities, but instead of, for instance, wheat, `@commodity="labor"` would be counted in `@unit="day"` or `@unit="month"`

    ```xml
    Imagine, someone bought <measureGrp><measure commodity="wheat" quantity="2" unit="kile">
    two kile of wheat</measure> at the price of <measure commodity="currency" quantity="3" 
    unit="ops">Ps 3</measure></measureGrp>.
    ```

    ```xml
    <measureGrp>
        <measure commodity="wheat" unit="kile" quantity="1">kile  | wheat </measure> | 
        <measure commodity="currency" unit="ops" quantity="50">50</measure> | 
        <measure commodity="currency" unit="ops" quantity="56">56</measure>
    </measureGrp>
    ```

3. *Temporal information*: The precision and duration of dates differs between sources; some provide information on a single date fixed in time, others provide similar punctual information but without it being fixed in time, yet others provide information on periods longer or shorter than a single day. 
    + `@when`: For the first and the third scenario, `<measureGrp>` and `<measure>` elements denoting the price can be dated with the `@when` attribute. If all measures are dated to the same moment/period, the attributes go on the wrapping `<measureGrp>`

    ```xml
    <tei:measureGrp when="1865-03-14">Yesterday, <tei:measure commodity="wheat" unit="kile"
     quantity="1">a kile of best wheat</tei:measure> was sold for <tei:measure commodity="currency" 
     unit="ops" quantity="38">Ps 38</tei:measure> to <tei:measure commodity="currency" unit="ops" 
     quantity="42">Ps 42</tei:measure></tei:measureGrp>
    ```


    ```xml
    Last week <tei:measureGrp>the price for <tei:measure commodity="wheat" unit="kile" 
     quantity="1">a kile of best wheat</tei:measure> rose from <tei:measure commodity="currency" 
     unit="ops" quantity="38" when="1863-03-20">Ps 38</tei:measure> to <tei:measure 
     commodity="currency" unit="ops" quantity="42" when="1863-03-25">Ps 42</tei:measure>
    </tei:measureGrp>.
    ```

    + `@dur`: in order to specify a duration, one can use the `@dur` attribute whith the datatype [`xs:duration`](https://docstore.mik.ua/orelly/xml/schema/ch16_01.htm#ch16-77046) / [`teidata.duration.w3c`](http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-teidata.duration.w3c.html).
    
    >The lexical space of `xs:duration` is the format defined by ISO 8601 under the form "PnYnMnDTnHnMnS," in which the capital letters are delimiters and can be omitted when the corresponding member is not used. 

4. *Spatial information*: Since non-metrical measures varied between places and since source can record prices from more than one location, the location can be specified with a custom `@location` attribute on `<measureGrp>` and `<measure>` elements denoting the price. If all measures relate to the same place, the attributes go on the wrapping `<measureGrp>`. `@location` accepts simple toponyms.

### open questions

How to encode the following:

>one of our compatriots reports that the price of wheat has been falling for the last two weeks and by some Ps 6 per kile. But the price of bread did not fall correspondingly. not even by a para. We inform the baladiyya about this issue

or this:

>we read in our last number that the price for a bushel of wheat rose by Ps 1. instead of falling it increased for another Ps 1. this is despite the rains, which should lower the prices

## 2. reference manager

All transcription and annotation of sources is done in Sente, which, albeit now discontinued, still runs without a glitch.

Data can be extracted from Sente using either the built-in XML export or my custom workflow published [here](https://www.github.com/tillgrallert/lossless-sente-export). The direct export has some glitches and data must be cleaned / pre-processed using [custom XSLT](https://www.github.com/tillgrallert/tss_tools).

## 3. extract and normalize price data 

The XSLT stylesheet [`tei_retrieve-measures-as-csv.xsl`](xslt/tei_retrieve-measures-as-csv.xsl) can be run on any input XML. It will gather all `<measureGrp>` elements based on a number of selection criteria and outputs them as CSV sorted by date (either publication date of the source or the date recorded  `@when` attributes). With the help of [`tei-measure_normalize.xsl`](xslt/tei-measure_normalize.xsl) units are normalised as far as possible to allow for greater comparability across the dataset. The stylesheet performs the following steps using different modes:

1. extract data: all `<tei:measureGrp>` are extracted from a folder containing one Sente XML file per source.
2. enrich every `<tei:measure>` with dates and locations based on information from ancestors `<tei:measureGrp>` and `<tss:reference>`. These are performed by `@mode="m_enrich-dates"`, `@mode="m_enrich-locations"`, and `@mode="m_enrich"`
    + in case `@when` provides information on a single year only, the stylesheet automatically adds `@dur="P1Y"`
3. normalize non-metrical measures: this is done with a [parameter file](xslt/tei-measure_parameters.xsl) that records localised and dated information on conversion rates between different units; e.g. 

    ```xml
    <!-- Nablus: volumes -->
    <tei:measureGrp type="volume" location="Nablus" source="83D74086-8E7D-4D96-9638-03F2A5BEA10F" when="1893">
        <tei:measure unit="tabba" quantity="12"/>
        <tei:measure unit="kile" quantity="10"/>
    </tei:measureGrp>
    <!-- Tripoli: volumes -->
    <tei:measureGrp type="volume" location="Tripoli" source="243D3AEC-773E-450D-A993-A1B8321A3B7D" when="1873">
        <tei:measure unit="shunbul" quantity="1"/>
        <tei:measure unit="kile" quantity="2.5"/>
    </tei:measureGrp>
    ```

    [*NOTE*]: this step also includes a normalization of various denominations of a currency, such as Ottoman *mecidiye*, *ġurūş*, *līra*, into a single denomination (piaster or "ops" in the Ottoman case). It is important that the stylesheets in question do not attempt to normalize denominations across currencies, without information on exchange rates (the final output of this conversion can be used as a basis for looking up exchange rates, so they should not be touched in this step).

4. regularize all commodities that are not money to quantities of 1 
5. safe output as xml and csv

## 4. Statistics and plots with R

After playing around with various R scripts, all data processing and plotting is done with a [single R script](r/prices.R).

There are two main plots of quantitative price data:

1. plot all values or seasonal averages over the entire period

    ![Scatter plot of daily average prices for wheat](https://github.com/tillgrallert/food-riots_data/raw/master/plots/rplot_prices-wheat-1874-1916_scatter-lines.png)

    ![Box plot of wheat prices](https://github.com/tillgrallert/food-riots_data/raw/master/plots/rplot_prices-wheat-1874-1916_box-plot.png)

2. plot all years over each other in order to see seasonal trends 

    ![seasonal fluctuation of wheat prices](https://github.com/tillgrallert/food-riots_data/raw/master/plots/rplot_prices-wheat-1874-1916_annual-cycle-box.png)

- *to do*:
    + add some weighing mechanism based on the information in `@dur`

# qualitative price information
## mark-up?

For the time being, I settled on manually tagging each reference in Sente that includes qualitative price information with the following tags:

- `prices: high`: 1
- `prices: rising`: 2
- `prices: stable`: 3
- `prices: falling`: 4
- `prices: low`: 5
- `prices: normal`: 6

## extract information

If the information is explicitly marked-up in Sente, export is simple and similar to that of quantitative information. Otherwise, one would need to run co-location analysis for pairs of words on the entire source corpus and record the result in some serialisation format. 

The stylesheet [`tss_retrieve-qualitative-prices.xsl`](xslt/tss_retrieve-qualitative-prices.xsl) extracts all explicitly marked-up price information from `<tss:keyword>` as CSV with the columns:

- date: publication date for the source
- location: publication place of the source
- source: a Sente UUID identifying the source
- tag: the qualitative tag

## statistics and plots with R

The CSV generated by `tss_retrieve-qualitative-prices.xsl` is used to plot this qualitative data in R. One can use the `geom_point()` function from ggplot to plot dots for each mention of a tag on a temporal axis; e.g. 

```r
ggplot() +
# layer: falling prices
geom_point(data = filter(v.Prices.Trends.Period, tag=="prices: high"), # filter data frame of qualitative data for a specific tag 
            aes(x = date, y = 9, # using a fixed value for y puts all dots on the same horizontal line
                colour = tag),
            fill = "#871020",
            shape=21, size=4, alpha = 0.3) # using a low alpha value allows to visually identify overlap and clustering
```

![Plot of trend data](https://github.com/tillgrallert/food-riots_data/raw/master/plots/rplot_prices-wheat-1874-1916_trends.png)





[^1]: Unfortunately, I originally recorded £T as `@unit="lt"`. The normalizing code takes care of this ambiguity.