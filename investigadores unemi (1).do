
. import excel "C:\Users\USER\Desktop\trabajo de investigacion\datos ecuador.xlsx", sheet("Hoja1") firstrow
describe
clear
destring p43, replace ignore("$ , .")
drop if p43 == .
destring p10a, replace ignore("$ , .")
drop if p10a == .
destring rama1, replace ignore("$ , .")
drop if rama1 == .


// RENOMBRAR VARIABLES //
rename p43 Estabilidad 
rename p10a Nivel_educativo
rename p03 Edad 
rename p02 Sexo 
rename rama1 sector_laboral 


* Primero defines las etiquetas de valores
label define sector_laboral ///
    1  "Agricultura, ganadería, silvicultura y pesca" ///
    2  "Explotación de minas y canteras" ///
    3  "Industrias manufactureras" ///
    4  "Suministro de electricidad, gas, vapor y aire acondicionado" ///
    5  "Distribución de agua, alcantarillado, gestión de desechos" ///
    6  "Construcción" ///
    7  "Comercio al por mayor y al por menor; reparación de vehículos" ///
    8  "Transporte y almacenamiento" ///
    9  "Alojamiento y servicios de comida" ///
    10 "Información y comunicación" ///
    11 "Actividades financieras y de seguros" ///
    12 "Actividades inmobiliarias" ///
    13 "Actividades profesionales, científicas y técnicas" ///
    14 "Actividades de servicios administrativos y de apoyo" ///
    15 "Administración pública, defensa y seguridad social obligatoria" ///
    16 "Enseñanza" ///
    17 "Actividades de atención de la salud humana y asistencia social" ///
    18 "Artes, entretenimiento y recreación" ///
    19 "Otras actividades de servicios" ///
    20 "Actividades de los hogares como empleadores de personal doméstico" ///
    21 "Actividades de organizaciones y órganos extraterritoriales"

* Luego asignas la etiqueta a tu variable
label values sector_laboral sector_laboral

* Crear variable binaria de estabilidad
gen estable = (Estabilidad == 2)
label define estable_lbl 0 "No estable" 1 "Estable"
label values estable estable_lbl

gen estable2_ajus = 0
replace estable2_ajus= 1 if Estabilidad == 1 | Estabilidad == 2

gen estable2= .
replace estable2 = 1 if Estabilidad == 2
replace estable2 = 0 if inlist(Estabilidad,1,3,4,5,6)

label define lbl_est 0 "No estable" 1 "Estable"
label values estable2 lbl_est




tab estable2

label define Nivel_educacion 1 "Ninguno" ///
                          2 "Centro de alfabetización" ///
                          3 "Jardín de Infantes" ///
                          4 "Primaria" ///
                          5 "Educación Básica" ///
                          6 "Secundaria" ///
                          7 "Bachillerato" ///
                          8 "Superior no Universitario" ///
                          9 "Superior Universitario" ///
                          10 "Post-grado"

label values Nivel_educativo Nivel_educacion


egen edad_rango = cut(Edad), group(5)
label define edad_label 1 "18-29 años" 2 "30-39 años" 3 "40-49 años" 4 "50-59 años" 5 "60 años o más"
label values edad_rango edad_label
tab Estabilidad


svyset upm [pweight=fexp] 
svy: logit  estable2_ajus i.Nivel_educativo i.Sexo i.edad_rango i.sector_laboral
estat gof
linktest
regress estable2_ajus i.Nivel_educativo i.Sexo i.edad_rango i.sector_laboral
vif
logit estable2_ajus i.Nivel_educativo i.Sexo i.edad_rango i.sector_laboral
ssc install asdoc
asdoc logit estable2_ajus i.Nivel_educativo i.Sexo i.edad_rango i.sector_laboral, save(tabla1.doc) replace dec(3)
estat classification

// curva de roc // 
lroc
margins Nivel_educativo
asdoc margins Nivel_educativo, save(tabla2.doc) replace dec(3)
margins edad_rango
margins sector_laboral 
asdoc margins sector_laboral, save(tabla3.doc) replace dec(3)
margins Nivel_educativo#sector_laboral 

margins Nivel_educativo
// Estabilidad por nivel educativo ///
marginsplot, recast(bar) ///
    ytitle("Probabilidad de empleo estable") ///
    xtitle("Nivel educativo") ///
    title("Probabilidad de estabilidad laboral por nivel educativo") ///
    xlabel(1 "Ninguno" 2 "Alfabetización" 3 "Inicial" 4 "Primaria" 5 "Básica" 6 "Secundaria" 7 "Bachillerato" 8 "Sup. no univ." 9 "Univ." 10 "Postgrado", angle(vertical))

	graph bar (percent), over(sector_laboral, sort(1)) ///
    blabel(bar, format(%9.1f)) ///
    ytitle("Porcentaje") ///
    title("Porcentaje de trabajadores por sector laboral")
// Ingreso promedio por sector laboral 
graph bar (mean) ingrl, over(sector_laboral, sort(1) label(angle(45) labsize(small))) ///
    blabel(bar, format(%9.0f) size(small) position(outside)) ///
    ytitle("Ingreso promedio (USD)") ///
    title("Ingreso promedio por sector laboral")
// Cantidad de personas estables por sector laboral///
	graph bar (count) estable if estable==1, over(sector_laboral, sort(1) label(angle(45) labsize(small))) ///
    blabel(bar, size(small) position(outside)) ///
    ytitle("Número de personas estables") ///
    title("Personas estables por sector laboral")
// Sueldo promedio por nivel educativo ///	
	graph bar (mean) ingrl, over(Nivel_educativo, sort(1) label(angle(45) labsize(small))) ///
    blabel(bar, format(%9.0f) size(small) position(outside)) ///
    ytitle("Ingreso promedio (USD)") ///
    title("Ingreso promedio por nivel educativo")
// Grafico de cantidad de personas con estabilidad por nivel educativo//	
	graph bar (count) estable if estable==1, over(Nivel_educativo, sort(1) label(angle(45) labsize(small))) ///
    blabel(bar, size(small) position(outside)) ///
    ytitle("Número de personas estables") ///
    title("Personas estables por nivel educativo")

margins Nivel_educativo#sector_labora
marginsplot, xdimension(sector_laboral) by(Nivel_educativo) ///
    ytitle("Probabilidad de estabilidad") ///
    title("Probabilidad de estabilidad por sector y nivel educativo") ///
    plotopts(msymbol(O) msize(small)) ///
    xlabel(, labsize(small) angle(45))

margins educacion#sector_laboral
marginsplot, xdimension(sector_laboral) by(Nivel_educativo, cols(2)) ///
    ytitle("Probabilidad de estabilidad") ///
    plotopts(msymbol(O) msize(small)) ///
    xlabel(, labsize(small) angle(45)) ///
    title("Probabilidad de estabilidad por sector y nivel educativo")















