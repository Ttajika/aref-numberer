#import "translation.typ": *

#let cap_body(it) = {if it != none {return it.body}
else {return it}
}



//#autonumbering equations

// 
#let tjk_numb_style(tag,tlabel,name,numbering:"(1)") = {
 if tag == true or name != none {
   if name == none{
   return  it => "("+str(tlabel)+")"}
   else {return it => "("+str(name)+")"}
 }
 else {
   return  numbering
 } 
}


#let tell_labels(it) ={
  if type(it) == "label"{return it}
  else {return label(str(it))} 
}

#let auto-numbering-equation(tlabel, name:none, tag:false,numbering:"(1)", body) ={
        locate(loc =>{
        let  eql = counter("tjk_auto-numbering-eq" + str(tlabel))
        if eql.final(loc).at(0) == 1{
          [#math.equation(numbering: tjk_numb_style(tag,tlabel,name,numbering:numbering),block: true)[#body]
         #tell_labels(tlabel)]
         if tag == true{counter(math.equation).update(i => i - 1)}
          }
        
        else {
         [#math.equation(numbering:none,block: true)[#body] ]
        }
      })
}

//shorthand
#let aeq = auto-numbering-equation

#let heading_supplement(it, supplement,thenumber,lang:"en",dic:(en:(:))) ={
   if lang == "jp" and supplement in dic.at("jp").keys() {
     return thenumber + dic.at("jp").at(supplement) 
   }
   else {return it}
 }




//modify reference 
#let eq_refstyle(it,lang:"en",dic:(en:(:))) = {
  return  {
  let lbl = it.target
  let eq = math.equation
  let el = it.element
  let eql = counter("tjk_auto-numbering-eq"+str(lbl))
  eql.update(1)
  if el != none and el.func() == eq {
 
      link(lbl)[
      #numbering(
        el.numbering,
        ..counter(eq).at(el.location())
      ) ]
  } else if el != none and el.has("counter") {
      let c_eq = el.counter
     if el.supplement.text in dic.at(lang).keys(){
    link(lbl)[
     #dic.at(lang).at(el.supplement.text) #numbering(
      el.numbering,
      ..c_eq.at(el.location())
    )]
  } else {it}
  } else if el != none and el.func() == heading {
    let thenumber = numbering(
        el.numbering,
        ..counter(heading).at(el.location())
      )
    link(lbl)[#heading_supplement(it, it.element.supplement.text, thenumber,lang:lang,dic:dic)
    ]
  }
    else {it}
  }
}





//#reference multiple labels
//dictionary of plurals
#let plurals(single,dict) ={
  if single in dict.keys() {
    return dict.at(single)
  }else {return single}
}


//multiple references
#let refs(..sink,dict:plurals_dic,add:" and ",comma:", ") = {
  let args = sink.pos()
  let numargs = args.len()
  let current_titles = ()
  let titles_dic = (:)
  if numargs == 1 {link(ref(args.at(0)).target)[#ref(args.at(0))]}
  else {
  show ref: it => plurals(it.element.supplement.text,dict)
  ref(args.at(0)) + " "
  show ref: it => {
     let c_eq = it.element.counter
      numbering(it.element.numbering,
      ..c_eq.at(it.element.location()))
  }
  if numargs == 2{link(ref(args.at(0)).target)[#ref(args.at(0))] + ""+ add +"" + link(ref(args.at(1)).target)[#ref(args.at(1))]}
  else{
  for i in range(numargs){
   if i< numargs - 1 {link(ref(args.at(i)).target)[#ref(args.at(i))] + comma+"" }
   else {add+"" + link(ref(args.at(i)).target)[#ref(args.at(i))]}
  }}
  }
}
  
