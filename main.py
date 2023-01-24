from flask import Flask,render_template,request,session,redirect
import json
from wtforms import SubmitField, SelectField, RadioField, HiddenField, StringField, IntegerField, FloatField,validators,SelectMultipleField,widgets,BooleanField
from wtforms.ext.sqlalchemy.fields import QuerySelectField

from flask_bootstrap import Bootstrap
from flask_wtf import FlaskForm
from wtforms.fields.html5 import DateField,DateTimeField

import flask_nav.elements as navb
from flask_nav import Nav
import psycopg2

conn=psycopg2.connect(
    host="localhost",
    database="swimmanager",
    user="postgres",
    password="postgres"
)
bar=navb.Navbar('Swim Manager',navb.View('Dodaj Trenera','add_trener'),
navb.View('Dodaj Zawodnika','add_zawodnik'),
navb.View('Adresy','adresy'),
navb.View('Wyniki','wyniki'),
navb.View('Dodaj Zawody','add_zawody'),
navb.View('Zobacz wyniki zawodnika','show_wyniki_zawodnika'),
navb.View('Zobacz wyniki wg zawodow',"show_wyniki_zawodow"),
navb.View("Dodaj Wynik","add_wynik")
)
nav=Nav()
nav.register_element('top',bar)
app =Flask(__name__)
bootstrap=Bootstrap(app)
import os
app.config.update(dict(
    SECRET_KEY="powerful secretkey",
    WTF_CSRF_SECRET_KEY="a csrf secret key"
))
class MultiCheckboxField(SelectMultipleField):
    widget = widgets.ListWidget(html_tag='ul', prefix_label=False)
    option_widget = widgets.CheckboxInput()
class DeleteForm(FlaskForm):
    name=SelectField()
    submit=SubmitField("Zatwierdź")

class AddZawodnik(FlaskForm):
    name=StringField('Imię')
    surname=StringField('Nazwisko')
    gender=SelectField('Płeć',choices=[('K','Kobieta'),('M','Mężczyzna')])
    town=StringField('Miejscowość')
    street=StringField('Ulica')
    house_num=IntegerField('Numer budynku')
    apt_num=IntegerField('Numer lokalu',validators=[validators.optional()])
    pesel=IntegerField('Pesel')
    post_code=StringField('Kod Pocztowy')
    submit=SubmitField('Dodaj Zawodnika')
class ChooseSwimmer(FlaskForm):
    cursor=conn.cursor()
    cursor.execute("Select id_zawodnika,imie ||' '||nazwisko from zawodnicy ")
    swimmers=cursor.fetchall()
    cursor.close()
    player=SelectField("Zawodnik",choices=swimmers)
    submit=SubmitField("Wybierz zawodnika")
class ChooseZawody(FlaskForm):
    cursor=conn.cursor()
    cursor.execute("Select id_zawodow,nazwa  from zawody ")
    zaw=cursor.fetchall()
    cursor.close()
    player=SelectField("Zawody",choices=zaw)
    submit=SubmitField("Wybierz zawody")
    
class DodajWynik(FlaskForm):
    cursor=conn.cursor()
    cursor.execute("Select id_zawodow,nazwa from zawody")
    choice=cursor.fetchall()
    
    cursor.execute("Select id_konkurencji,nazwa_konkurencji from konkurencje" )
    cursor.close()
    zawody=SelectField("Zawody",choices=choice)
    submit=SubmitField("Zatwierdź")
class Wynik2(FlaskForm):
    id=0
    cursor=conn.cursor()
    cursor.execute("Select id_konkurencji,nazwa_konkurencji from konkurencje where id_konkurencji in(Select id_konkurencji from zawody_konkurencje where id_zawodow=%s)",[id])
    choic=cursor.fetchall()
    cursor.execute("Select z.id_zawodnika, z.imie||' '||z.nazwisko from zawodnicy z")
    zawodnicy=cursor.fetchall()
    konkurencja=SelectField("Konkurencja",choices=choic)
    zawodnik=SelectField("Zawodnik",choices=zawodnicy)
    czas=FloatField("Czas")
    submit1=SubmitField("Zatwierdź")
class AddTrener(FlaskForm):
    name=StringField('Imię')
    surname=StringField('Nazwisko')
    town=StringField('Miejscowość')
    street=StringField('Ulica')
    house_num=IntegerField('Numer budynku')
    apt_num=IntegerField('Numer lokalu',validators=[validators.optional()])
    pesel=IntegerField('Pesel')
    post_code=StringField('Kod Pocztowy')
    submit=SubmitField('Dodaj Zawodnika')

class ChooseGroup(FlaskForm):
    cursor=conn.cursor()
    cursor.execute("SELECT id_grupy,nazwa FROM GRUPY")
    gr=cursor.fetchall()
    cursor.close()
    grupa=SelectField(choices=gr)
class AddZawody(FlaskForm):
    name=StringField('Nazwa Wydarzenia')
    
    type_of_event=RadioField(label='Typ wydarzenia',choices=[('tr','Trening'),('zaw','Zawody')])
    cur=conn.cursor()
    cur.execute('Select id_konkurencji,nazwa_konkurencji from konkurencje')
    wyb=cur.fetchall()
    checkboxes={}
   
    mul=SelectMultipleField(choices=wyb,coerce=int,validate_choice=False)
    
    
        
    date=DateField()
    
    cur.execute("Select id_obiektu,nazwa from obiekty")
    locations=cur.fetchall()
    cur.close()
    print(locations)
    choose_location=SelectField('Lokalizacja',choices=locations)
    
    submit=SubmitField()
@app.route('/konkurencje',methods=['GET'])
def konkurencje():
    id=request.args.get("id_zawodow")
    cur=conn.cursor()
    cur.execute("Select kz.id_konkurencji from zawody_konkurencje kz  inner join konkurencje k on kz.id_konkurencji=k.id_konkurencji where id_zawodow=%s",[id])
    return json.JSONEncoder().encode({"list":cur.fetchall()})
@app.route('/wyniki')
def wyniki():
    cur=conn.cursor()
    cur.execute("SELECT * FROM NAZWISKA_Wyniki")
    z=cur.fetchall()
    cur.close()
    return render_template("wyniki1.html",value=z)
    
@app.route('/zawody')
def zawody():
    cur=conn.cursor()
    cur.execute("SELECT * FROM NAZWISKA_ZAWODY")
    z=cur.fetchall()

@app.route('/')
def home():
    return render_template("home.html")

@app.route('/adresy')
def adresy():
    cur=conn.cursor()
    cur.execute("SELECT * FROM public.obiekty",)
    z=cur.fetchall()
    cur.close()
    return render_template("adresy.html",value=z)

@app.route('/add_zawodnik',methods=['GET','POST'])
def add_zawodnik():
    response=""
    form=AddZawodnik()
    if form.validate_on_submit():
        name=(form.name).data
        surname=(form.surname).data
        gender=(form.gender).data
        town=(form.town).data
        street=(form.street).data
        house_num=(form.house_num).data
        apt_num=(form.apt_num).data
        pesel=(form.pesel).data
        post_code=(form.post_code).data
        cur=conn.cursor()
        
        cur.execute('select * from zawodnicy where pesel=%s::numeric',[pesel])
        if ((cur.rowcount>0)):
            response="Zawodnik o podanym peselu już istnieje"
        else:
            cur.execute('call dodaj_zawodnika(%s::varchar,%s::varchar,%s::numeric,%s::varchar,%s::varchar,%s::varchar,%s,%s,%s,%s::char(1))',[name,surname,pesel,street,post_code,town,house_num,apt_num,1,gender])

            conn.commit()
            cur.execute('select * from zawodnicy where pesel=%s::numeric',[pesel])
            if (cur.rowcount>0):
                response=f"Dodano zawodnika {name} {surname}"
            else:
                response="Niepowodzenie"
        cur.close()
        
    return render_template('add_zawodnik_form.html',form=form,response=response)
@app.route('/add_trener',methods=['GET','POST'])
def add_trener():
    form=AddTrener()
    response=""
    if form.validate_on_submit():
        name=(form.name).data
        surname=(form.surname).data
        town=(form.town).data
        street=(form.street).data
        house_num=(form.house_num).data
        apt_num=(form.apt_num).data
        if apt_num==0:
            apt_num=None
        pesel=(form.pesel).data
        post_code=(form.post_code).data
        
        cur=conn.cursor()
        cur.execute('select * from trenerzy where pesel=%s::numeric',[pesel])
        if ((cur.rowcount>0)):
            response="Trener o podanym peselu już istnieje"
        else:
            cur.execute('call dodaj_trenera(%s::varchar,%s::varchar,%s::numeric,%s::varchar,%s::varchar,%s::varchar,%s,%s,%s)',[name,surname,pesel,street,post_code,town,house_num,apt_num,1])
            conn.commit()
            cur.execute('select * from trenerzy where pesel=%s::numeric',[pesel])
            if (cur.rowcount>0):
                response=f"Dodano Trenera {name} {surname}"
            else:
                response="Niepowodzenie"
        cur.close()
        
    return render_template('add_zawodnik_form.html',form=form,response=response)


@app.route('/add_zawody',methods=['GET','POST'])
def add_zawody():
    form=AddZawody()
    
    
    if form.validate_on_submit():
        zawody=(form.name).data
        
        type_of_event=(form.type_of_event).data
        location=(form.choose_location).data
        date=(form.date).data
        choices=(form.mul).data
        result=[]
        cur=conn.cursor()
        if (type_of_event!='tr'):
            cur.execute('insert into zawody(nazwa,data_zawodow,id_obiektu) values(%s,%s,%s) ',[zawody,date,location])
            for data in choices:
                cur.execute('insert into zawody_konkurencje(id_zawodow,id_konkurencji) values((select id_zawodow from zawody where data_zawodow=%s and id_obiektu=%s),%s)',[date,location,data])
        else:
            cur.execute('insert into treningi(data_treningu,id_obiektu) values(%s,%s) ',[date,location])
            for data in choices:
                cur.execute('insert into treningi_konkurencje(id_zawodow,id_konkurencji) values((select id_treningu from treningi where data_treningu=%s and id_obiektu=%s),%s)',[date,location,data])
            
        conn.commit()
        cur.close()
        
            

        
    return render_template('add_zawodnik_form.html',form=form)
@app.route('/show_wyniki',methods=['GET','POST'])
def show_wyniki_zawodnika():
    form=ChooseSwimmer()
    val=["",""]
    
    
    if form.validate_on_submit():
        zawodnik=(form.player).data
        cur =conn.cursor()
        cur.execute('select * from nazwiska_wyniki where id_zawodnika=%s;',[zawodnik])
        val=cur.fetchall()
        cur.close()
        
    return render_template('wyniki.html',form=form,value=val)

@app.route('/show_wyniki_zawodow',methods=['GET','POST'])
def show_wyniki_zawodow():
    form=ChooseZawody()
    val=["",""]
    if form.validate_on_submit():
        zawody=(form.player).data
        cur=conn.cursor()
        cur.execute(  " select * from wyniki_zawody where id_zawodow =%s;",[zawody])
        val=cur.fetchall()
        cur.close()
    return render_template('wyniki.html',form=form,value=val)
@app.route('/add_wynik',methods=["POST","GET"])

def add_wynik():
    
    form=DodajWynik()
    
    ready=False
    if form.validate_on_submit() :

        
        cursor=conn.cursor()
        cursor.execute("Select id_konkurencji,nazwa_konkurencji from konkurencje where id_konkurencji in(Select id_konkurencji from zawody_konkurencje where id_zawodow=%s)",[(form.zawody).data])
        choic=cursor.fetchall()
        cursor.close()
        session['choic']=choic
        session['id']=(form.zawody).data
        return redirect('/add_wynik2')
        

    return render_template("add_zawodnik_form1.html",form=form)
@app.route('/add_wynik2',methods=["POST","GET"])
def add_wynik2():
    form1=Wynik2()
    curso=conn.cursor()
    form1.konkurencja.choices=session['choic']
    curso.execute("Select z.id_zawodnika, z.imie||' '||z.nazwisko from zawodnicy z")
    zawodnicy=curso.fetchall()
    curso.close()
    form1.zawodnik.choices=zawodnicy
    if form1.validate and form1.submit1.data:
                cursor=conn.cursor()
                id=session['id']
                cursor.execute("Insert into wyniki(id_konkurencji,id_zawodow,id_zawodnika,czas) values(%s,%s,%s,%s)",[(form1.konkurencja).data,id,(form1.zawodnik).data,(form1.czas).data])
                conn.commit()
                cursor.close()
    return render_template("add_zawodnik_form1.html",form=form1)
@app.route('/show_grupy',methods=["POST","GET"])
def show_grupy():
    form =ChooseGroup()
    if form.validate_on_submit:
        None
@app.route('/delete_zawodnik',methods=["POST","GET"])
def delete_z():
    form=DeleteForm()
    response=""
    cursor=conn.cursor()
    cursor.execute("SELECT id_zawodnika, imie||' '||nazwisko from zawodnicy ")
    ch=cursor.fetchall()
    (form.name).choices=ch
    cursor.close()
    if form.validate_on_submit():
        cursor=conn.cursor()
        cursor.execute("select imie||' '||nazwisko from zawodnicy where id_zawodnika=%s",[form.name.data])
        nam=cursor.fetchone()
        cursor.execute("delete from zawodnicy where id_zawodnika=%s ",[form.name.data])
        response=f"Usunieto zawodnika  {nam[0] } o id{form.name.data}"
        conn.commit()
        cursor.close()
    return render_template('add_zawodnik_form.html',form=form,response=response)
nav.init_app(app)
app.run()
