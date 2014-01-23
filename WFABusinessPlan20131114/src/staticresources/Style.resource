/* Begin Reset */
	html, body, div, span, applet, object, iframe, h1, h2, h3, h4, h5, h6, p, blockquote, pre, a, abbr, acronym, address, big, cite, code, del, dfn, em, font, img, ins, kbd, q, s, samp, small, strike, strong, sub, tt, var, dl, dt, dd, ol, ul, li, fieldset, form, label, legend, table, caption, tbody, tfoot, thead, tr, th, td {
	    margin: 0;
	    padding: 0;
	    border: 0;
	    outline: 0;
	    font-weight: inherit;
	    font-style: inherit;
	    font-size: 100%;
	    font-family: inherit;
	    vertical-align: baseline;
	}
	/* no focus styles are set */
	:focus { outline: 0; }
	body {
	    line-height: 1;
	    color: black;
	    background: white;
	}
/* End Reset */

/* BEGIN General Settings */
	body {font-family: Arial, Helvetica, Verdana, sans-serif;}
	.pagewrap {width: 634px; margin: 0 auto; padding: 0;}		
/* END General Settings */

/* BEGIN Table CSS */
h1 {
    display:block; width:637px; padding:34px 0 28px;
    font-size:18px; line-height:23px; text-align:center; font-weight:normal;
}
.tabletop {
    display:block; width:630px; height:15px; 
    background:transparent url(images/top.gif) no-repeat scroll 0 0;
    margin:0 0 0 4px;
}
.tablebk {
    width:615px;
    background:transparent url(images/middle.gif) repeat-y scroll 0 0;
    margin:0 0 0 4px; padding:0 0 0 15px;
}
.tablebottom {
    display:block; width:630px; height:16px; 
    background:transparent url(images/bottom.gif) no-repeat scroll 0 0;
    margin:0 0 0 4px;
}

table {table-layout:fixed; border-collapse:collapse; border-spacing:0; }
th, td {border:1px solid #999; text-align:center; font-weight:bold; }
th {
    color:#fff; background-color:#0141ab;
    font-size:16px; line-height:22px;
    padding:5px 11px 8px;
}
td {
    color:#000; background-color:#d9e8f0;
    font-size:14px; line-height:16px;
    padding:11px;
    vertical-align:top;
}
th.col1,
td.col1 {text-align:left;}
.odd td {background-color:#f2f7fa;}

td input {
    width:85px; height:22px;
    font-size:14px; line-height:16px; font-weight:bold; text-align:center;
    padding-top:3px;
    border:1px solid #999;
}

tr:hover td {background-color:#599bbd;} /* hover state does not work in ie6 */

/* table1 */
.table1 th.col1 {width:176px; }
.table1 th.col2 {width:181px;}
.table1 th.col3 {width:173px;}
.table1 td {padding-bottom:5px;}
.table1 td.col3 {padding-top:6px; padding-left:19px;}

/* table2 */
.table2 th.col1 {width:176px;}
.table2 th.col2 {width:181px;}
.table2 th.col3 {width:173px;}

/* table3 */
.table3 th.col1 {width:128px;}
.table3 th.col2 {width:153px;}
.table3 th.col3 {width:130px;}
.table3 th.col4 {width:95px;}
.table3 td {padding-bottom:5px;}
.table3 td.col4 {padding-top:6px; padding-left:19px;}
/* END Table CSS */

/* Previous/Next Links */
.prevnext {
	float:left;
    list-style-type:none; 
    font-size:14px; line-height:16px;
    padding:0 0 0 12px;
    overflow:hidden;
}
.prevnext li {float:left;}
.prevnext a {
    display:block; padding:6px; margin:0 5px 0 0;
    border:1px solid #999; 
    text-decoration:none; color:#000; background-color:#D9E8F0;
}
.prevnext a:hover {
    border:1px solid #000; 
    background-color:#599bbd;
}
/* Add to cart */
.addtocart {
	display:block;
	float:right;
	margin-right:9px;
}
