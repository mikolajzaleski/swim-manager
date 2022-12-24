from flask import Flask,render_template,request
import json
from wtforms import SubmitField, SelectField, RadioField, HiddenField, StringField, IntegerField, FloatField,validators
from flask_bootstrap import Bootstrap
from flask_wtf import FlaskForm
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
navb.View('Wyniki','wyniki')
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
        if apt_num==0:
            apt_num=None
        cur.execute('call dodaj_zawodnika(%s::varchar,%s::varchar,%s::numeric,%s::varchar,%s::varchar,%s::varchar,%s,%s,%s,%s::char(1))',[name,surname,pesel,street,post_code,town,house_num,apt_num,1,gender])
        conn.commit()
        cur.close()
    return render_template('add_zawodnik_form.html',form=form)
@app.route('/add_trener',methods=['GET','POST'])
def add_trener():
    form=AddTrener()
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
        cur.execute('call dodaj_trenera(%s::varchar,%s::varchar,%s::numeric,%s::varchar,%s::varchar,%s::varchar,%s,%s,%s)',[name,surname,pesel,street,post_code,town,house_num,apt_num,1])
        conn.commit()
        cur.close()
    return render_template('add_zawodnik_form.html',form=form)
nav.init_app(app)
app.run()
