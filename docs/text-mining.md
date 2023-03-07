text-mining
================

``` r
# See notes about interactive use and loading in exploratory document
mpeds <- tar_read(integrated) |>
  st_drop_geometry() 

mpeds_text <- mpeds |> 
  select(key, issues, actors, movement_organizations) |> 
  pivot_longer(c(issues, actors, movement_organizations),
              names_to = "variable", values_to = "text") |> 
  unnest(text) |> 
  group_by(key) |> 
  mutate(document_id = paste(key, variable, sep = "_")) |> 
  ungroup() |> 
  unnest_tokens(word, text)
```

# `tf-idf`

Focusing solely on the text-selects from issues, actors, and movement
organizations:

``` r
tfidf_by_subgroup <- function(subgroup){
  mpeds_tf <- mpeds_text |> 
    filter(variable == subgroup) |> 
    group_by(document_id) |> 
    mutate(n_document = n()) |> # how many words in entire document
    group_by(key, document_id, word) |> 
    summarize(n_word = n(), # how many times a particular term appears in document
              .groups = "drop") |> 
    bind_tf_idf(word, document_id, n_word) |> 
    arrange(desc(tf_idf))
  
  head(mpeds_tf, 15) |> 
    select('Event Key' = key, 
           word, tf, idf, tf_idf) |> 
    kable(caption = paste0("tf-idf for ", str_replace(subgroup, "_", " ")))
}

tfidf_by_subgroup("issues")
```

| Event Key                                                  | word            |  tf |      idf |   tf_idf |
|:-----------------------------------------------------------|:----------------|----:|---------:|---------:|
| 20160923_Muncie_Demonstration_OtherIssue                   | slutwalk        |   1 | 8.607217 | 8.607217 |
| 20171114_Manhattan_March_CampusClimate                     | ksunite         |   1 | 8.607217 | 8.607217 |
| 20180228_SanFrancisco_March_Immigration(For)               | iceoutofca      |   1 | 8.607217 | 8.607217 |
| 20170209_BatonRouge_OtherIssue                             | christianity    |   1 | 7.220922 | 7.220922 |
| 20151001_Easton_Rally_Environmental                        | sustainability  |   1 | 6.815457 | 6.815457 |
| 20180320_Fresno_TransgenderIssuesFor                       | preaching       |   1 | 6.527775 | 6.527775 |
| 20120620_SantaCruz_LabourAndWork                           | afscme          |   1 | 6.304632 | 6.304632 |
| 20161110_WestLongBranch_March_OtherIssue                   | bigotry         |   1 | 6.042267 | 6.042267 |
| 20171204_Edwardsville_Rally_LabourAndWork                  | raises          |   1 | 5.899166 | 5.899166 |
| 20180403_Sacramento_Rally_Prolaw                           | policing        |   1 | 5.899166 | 5.899166 |
| 20160114_Calgary_Informationdistribution_Abortion(Against) | abortions       |   1 | 5.774003 | 5.774003 |
| 20180509_Laramine_Petition_UniversityGovernance            | funds           |   1 | 5.716845 | 5.716845 |
| 20140801_Regina_Boycott_Pro-Palestine                      | israel          |   1 | 5.516174 | 5.516174 |
| 20170830_Greeley_Vigil_FarRight(Against)                   | charlottesville |   1 | 5.388341 | 5.388341 |
| 20150318_LongBeach_Rally_LGBFor                            | lgbt            |   1 | 4.996299 | 4.996299 |

tf-idf for issues

``` r
tfidf_by_subgroup("actors")
```

| Event Key                                         | word           |  tf |      idf |   tf_idf |
|:--------------------------------------------------|:---------------|----:|---------:|---------:|
| 20161114_Seattle_Walkout_Trump(Against)           | walkouts       |   1 | 8.531885 | 8.531885 |
| 20170901_Ottawa_Petition_OtherIssue               | masjedee       |   1 | 8.531885 | 8.531885 |
| 20140916_SouthKingstown_Rally_OtherIssue          | missionaries   |   1 | 7.433273 | 7.433273 |
| 20141008_Atlanta_Rally_LGB+(Against)              | preachers      |   1 | 7.433273 | 7.433273 |
| 20150327_Montreal_Demonstration_EconomyInequality | montrealers    |   1 | 7.145590 | 7.145590 |
| 20150301_Toronto_Strike_Labor                     | tas            |   1 | 6.585975 | 6.585975 |
| 20161111_Rochester_Rally_OtherIssue               | veterans       |   1 | 6.046978 | 6.046978 |
| 20131204_Chattanooga_Rally_OtherIssue             | preacher       |   1 | 5.892827 | 5.892827 |
| 20160923_Muncie_Demonstration_OtherIssue          | preacher       |   1 | 5.892827 | 5.892827 |
| 20180325_Champaign-Urbana_Petition_Labor          | parents        |   1 | 5.823835 | 5.823835 |
| 20140417_Minneapolis_Rally_DomesticForeignPolicy  | protestors     |   1 | 5.536153 | 5.536153 |
| 20181102_Toronto_Demonstration_FarRightAgainst    | protestors     |   1 | 5.536153 | 5.536153 |
| 20151119_Cambridge_Rally_SexualAssault            | undergraduates |   1 | 5.487362 | 5.487362 |
| 20180218_Storrs_Immigration(Against)              | republicans    |   1 | 5.487362 | 5.487362 |
| 20180417_Boston_Petition_PoliceViolence           | petition       |   1 | 5.440842 | 5.440842 |

tf-idf for actors

``` r
tfidf_by_subgroup("movement_organizations")
```

| Event Key                                              | word             |  tf |     idf |  tf_idf |
|:-------------------------------------------------------|:-----------------|----:|--------:|--------:|
| 20120320_Montreal_Blockade_Tuition                     | classé           |   1 | 8.12148 | 8.12148 |
| 20131010_NewYorkCity_March_LGB                         | glass            |   1 | 8.12148 | 8.12148 |
| 20140124_St.John_NoForm_UniversityGov                  | unbsu            |   1 | 8.12148 | 8.12148 |
| 20140324_Portland_Walkout_UniversityGovernance         | umainefuture     |   1 | 8.12148 | 8.12148 |
| 20140401_LasCruces_Rally_LabourAndWork                 | moveon.org       |   1 | 8.12148 | 8.12148 |
| 20140923_Missoula_Rally_Environmental                  | reinvestmt       |   1 | 8.12148 | 8.12148 |
| 20141017_Ithaca_Rally_UniversityGovernance             | kyotonow         |   1 | 8.12148 | 8.12148 |
| 20141208_Gainesville_Rally_PoliceViolence              | blacklivesmatter |   1 | 8.12148 | 8.12148 |
| 20141208_Greenville_Demonstration_PoliceViolence       | injustus         |   1 | 8.12148 | 8.12148 |
| 20150101_Oakland_Strike_Labor                          | ulp              |   1 | 8.12148 | 8.12148 |
| 20150301_LosAngeles_Occupation_TransgenderIssues       | transup          |   1 | 8.12148 | 8.12148 |
| 20150301_Providence_March_SexualAssault                | act4rj           |   1 | 8.12148 | 8.12148 |
| 20150421_EwingTownship_March_SexualAssault             | will             |   1 | 8.12148 | 8.12148 |
| 20151201_Waltham_OtherForm_Universitygovernance        | baatf            |   1 | 8.12148 | 8.12148 |
| 20160331_Appleton_Symbolicdisplay_Universitygovernance | fulu             |   1 | 8.12148 | 8.12148 |

tf-idf for movement organizations

Hm, that went alright, if the purpose is to identify movement-specific
keywords that can be used to query twitter. There are some issues,
though:

1.  Text selects sometimes capture non-English words, that are given
    undue weight due to the majority of our documents being English-only
2.  “Documents” are very short, often a single phrase or sentence, or
    even just a few words
3.  tf-idf seems really good at finding proper nouns, like “iceoutofca”.
    Hopefully these can be used for Twitter search, but I’m worried
    they’re too specific for the kinds of scraping we want to do.
4.  This is a single-token analysis, not an n-gram analysis – that’s in
    the works, though it’s hard to tell what `n` should be exactly

Here’s one on the entire corpus that are linked to canonical events (an
article was linked to a row in `coder_event_creator`, and that row was
used for a canonical event).

``` r
articles <- tar_read(articles) |> 
  drop_na(canonical_key) |> 
  select(-title) |> 
  mutate(article_id = 1:n()) |> 
  unnest_tokens(word, text)

articles_tfidf <- articles |> 
  group_by(canonical_key, article_id, word) |> 
  summarize(n_word = n(), .groups = "drop") |> 
  bind_tf_idf(word, article_id, n_word) |> 
  arrange(desc(tf_idf))
  
head(articles_tfidf, 15) |> 
  select('Event Key' = canonical_key, 
         word, tf, idf, tf_idf) |> 
  kable(caption = "tf-idf for entire article corpus")
```

| Event Key                                          | word                 |        tf |      idf |    tf_idf |
|:---------------------------------------------------|:---------------------|----------:|---------:|----------:|
| 20170120_Honolulu_March_Trump(Against)             | dsc                  | 0.1730769 | 9.086476 | 1.5726594 |
| 20170120_Honolulu_March_Trump(Against)             | sony                 | 0.1730769 | 8.393329 | 1.4526916 |
| 20141001_Chicago_Rally_PoliceViolence              | 14police             | 0.0798859 | 9.086476 | 0.7258811 |
| 20170120_Corvallis_Walkout_Trump(Against)          | osuwalkout           | 0.0676329 | 9.086476 | 0.6145443 |
| 20180427_LosAngeles_Rally_AnimalRights             | animals              | 0.1176471 | 4.959342 | 0.5834520 |
| 20150501_WallaWalla_SymbolicDisplay_PoliceViolence | halley               | 0.0558659 | 9.086476 | 0.5076244 |
| 20131021_Ottawa_March_IndigenousIssues             | slideshowgallery2419 | 0.0532915 | 9.086476 | 0.4842323 |
| 20140424_Eugene_Disruption_AntiRacism              | asuo                 | 0.0539499 | 7.987864 | 0.4309445 |
| 20130307_Toronto_Disruption_Feminism               | flare                | 0.0666667 | 6.142037 | 0.4094692 |
| 20180327_Boston_Form_ImmigrationFor                | tps                  | 0.0555556 | 7.140566 | 0.3966981 |
| 20161109_Richmond_March_Trump(Against)             | clarkphoto           | 0.0465839 | 8.393329 | 0.3909936 |
| 20161109_Richmond_Vigil_Trump(Against)             | clarkphoto           | 0.0465839 | 8.393329 | 0.3909936 |
| 20120215_Saskatoon_Vigil_OtherIssue                | alsharief            | 0.0426829 | 9.086476 | 0.3878374 |
| 20141212_Towson_March_PoliceViolence               | towerlighttowson     | 0.0417827 | 9.086476 | 0.3796578 |
| 20130307_Toronto_Disruption_Feminism               | men’s                | 0.0666667 | 5.652489 | 0.3768326 |

tf-idf for entire article corpus

`slideshowgallery2419` and `clarkphoto` are included only because the
article texts in the database contain extra information within HTML tags
that cannot be filtered out programmatically (there is no structural
separation between those kinds of information and the article text
itself).
