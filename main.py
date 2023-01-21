from flask import Flask,render_template,request
import json
from wtforms import SubmitField, SelectField, RadioField, HiddenField, StringField, IntegerField, FloatField,validators
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
navb.View('Zobacz wyniki zawodnika','show_wyniki_zawodnika')
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
    
    
class AddZawody(FlaskForm):
    name=StringField('Nazwa Wydarzenia')
    
    type_of_event=RadioField(label='Typ wydarzenia',choices=[('tr','Trening'),('zaw','Zawody')])
   
        
    date=DateField()
    cur=conn.cursor()
    cur.execute("Select id_obiektu,nazwa from obiekty")
    locations=cur.fetchall()
    cur.close()
    print(locations)
    choose_location=SelectField('Lokalizacja',choices=locations)
    submit=SubmitField()
@app.route('/wyniki')
def wyniki():
    cur=conn.cursor()
    cur.execute("SELECT * FROM NAZWISKA_Wyniki")
    z=cur.fetchall()
    cur.close()
    return render_template("adresy.html",value=z)
    
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
        result=[]
        cur=conn.cursor()
        if (type_of_event!='tr'):
            cur.execute('insert into zawody(nazwa,data_zawodow,id_obiektu) values(%s,%s) ',[zawody,date,location])
        else:
             cur.execute('insert into treningi(data_treningu,id_obiektu) values(%s,%s) ',[date,location])
            
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
        cur.execute('select * from nazwiska_wyniki where id_zawodnika=%s',[zawodnik])
        val=cur.fetchall()
        cur.close()
        
    return render_template('wyniki.html',form=form,value=val)

    
nav.init_app(app)
app.run()
