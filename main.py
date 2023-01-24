from flask import Flask,render_template,request,session,redirect
import json
from wtforms import SubmitField, SelectField, RadioField, HiddenField, StringField, IntegerField, FloatField,validators,SelectMultipleField,widgets,BooleanField
#from wtforms.ext.sqlalchemy.fields import QuerySelectField

from flask_bootstrap import Bootstrap
from flask_wtf import FlaskForm
from wtforms.fields import DateField,DateTimeField

import flask_nav.elements as navb
from flask_nav import Nav
import psycopg2

conn=psycopg2.connect(
    host="localhost",
    database="swimmanager",
    user="swim",
    password="swim123"
)

bar=navb.Navbar(
navb.View('Swim Manager','home'),
navb.View('Trenerzy','trenerzy'),
navb.View('Zawodnicy','zawodnicy'),
navb.View('Kluby','kluby'),
navb.View('Obiekty sportowe','adresy'),
navb.View('Wyniki','wyniki'),
navb.View('Kalendarz zawodów','add_zawody'),
navb.View('Zobacz wyniki zawodnika','wyniki_zawodnika'),
navb.View('Zobacz wyniki wg zawodow',"wyniki_zawodow"),
navb.View("Dodaj Wynik","add_wynik")
)

nav=Nav()
nav.register_element('top',bar)
app =Flask(__name__)
bootstrap=Bootstrap(app)

app.config.update(dict(
    SECRET_KEY="powerful secretkey",
    WTF_CSRF_SECRET_KEY="a csrf secret key"
))
class MultiCheckboxField(SelectMultipleField):
    widget = widgets.ListWidget(html_tag='ul', prefix_label=False)
    option_widget = widgets.CheckboxInput()


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
    club=StringField('Klub sportowy')
    submit=SubmitField('Dodaj')

class ChooseSwimmer(FlaskForm):
    cursor=conn.cursor()
    cursor.execute("Select id_zawodnika,imie ||' '||nazwisko from zawodnicy ")
    swimmers=cursor.fetchall()
    cursor.close()
    player=SelectField("Zawodnik",choices=swimmers)
    submit=SubmitField("Wybierz zawodnika")

class ChooseZawody(FlaskForm):
    cursor=conn.cursor()
    cursor.execute("Select id_zawodow, nazwa  from zawody ")
    zaw=cursor.fetchall()
    cursor.execute("Select id_konkurencji, nazwa_konkurencji from konkurencje ")
    kon=cursor.fetchall()
    cursor.close()
    print(kon)
    zawody=SelectField("Zawody",choices=zaw)
    konkurencja=SelectField("Konkurencja",choices=kon)
    plec=SelectField("Płeć",choices=['M','K'])
    submit=SubmitField("Wybierz zawody")
    
class DodajWynik(FlaskForm):
    cursor=conn.cursor()
    cursor.execute("Select id_zawodow, nazwa from zawody")
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
    club=StringField('Klub')
    submit=SubmitField('Dodaj')

class AddKlub(FlaskForm):
    name=StringField('Nazwa')
    submit=SubmitField('Dodaj')

class ChooseGroup(FlaskForm):
    cursor=conn.cursor()
    cursor.execute("SELECT id_grupy,nazwa FROM GRUPY")
    gr=cursor.fetchall()
    cursor.close()
    grupa=SelectField(choices=gr)

class AddZawody(FlaskForm):
    name=StringField('Nazwa Wydarzenia')

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
    return render_template("wyniki_all.html",value=z)
    
@app.route('/zawody')
def zawody():
    cur=conn.cursor()
    cur.execute("SELECT * FROM NAZWISKA_ZAWODY")
    z=cur.fetchall()

@app.route('/kluby', methods=['GET','POST'])
def kluby():
    cur=conn.cursor()
    cur.execute("SELECT nazwa_klubu FROM public.kluby order by nazwa_klubu asc")
    z=cur.fetchall()
    cur.close()
    form=AddKlub()
    if form.validate_on_submit():
        name=(form.name).data
        cur=conn.cursor()
        
        cur.execute('select * from kluby where nazwa_klubu=%s',[name])
        if ((cur.rowcount>0)):
            response="Klub o podanej nazwie już istnieje"
        else:
            cur.execute('call dodaj_klub(%s::varchar)',[name])

            conn.commit()
            if (cur.rowcount>0):
                response=f"Dodano klub {name}"
            else:
                response="Niepowodzenie"
        cur.close()
    return render_template("kluby.html",form=form, value=z)

@app.route('/')
def home():
    return render_template("home.html")

@app.route('/adresy')
def adresy():
    cur=conn.cursor()
    cur.execute("SELECT nazwa, dane_adresowe FROM public.obiekty",)
    z=cur.fetchall()
    cur.close()
    return render_template("adresy.html",value=z)

@app.route('/zawodnicy',methods=['GET','POST'])
def zawodnicy():
    cur=conn.cursor()
    cur.execute("Select zw.imie, zw.nazwisko, zw.plec, kl.nazwa_klubu from public.zawodnicy zw inner join public.kluby kl on zw.id_klubu=kl.id_klubu order by zw.nazwisko asc, zw.imie asc")
    z=cur.fetchall()
    cur.close()

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
        club=(form.club).data
        cur=conn.cursor()
        
        cur.execute('select * from zawodnicy where pesel=%s::numeric',[pesel])
        if ((cur.rowcount>0)):
            response="Zawodnik o podanym peselu już istnieje"
        else:
            cur.execute('select * from kluby where nazwa_klubu=%s::varchar',[club])
            if (cur.rowcount==0):
                response="Zawodnik nie może tworzyć nowego klubu"
            else:
                cur.execute('call dodaj_zawodnika(%s::varchar,%s::varchar,%s::numeric,%s::varchar,%s::varchar,%s::varchar,%s,%s,%s::varchar,%s::char(1))',[name,surname,pesel,street,post_code,town,house_num,apt_num,club,gender])

                conn.commit()
                cur.execute('select * from zawodnicy where pesel=%s::numeric',[pesel])
                if (cur.rowcount>0):
                    response=f"Dodano zawodnika {name} {surname}"
                else:
                    response="Niepowodzenie"
        cur.close()
        
    return render_template('zawodnicy.html',form=form,response=response, value=z)

@app.route('/trenerzy',methods=['GET','POST'])
def trenerzy():
    cur=conn.cursor()
    cur.execute("Select tr.imie, tr.nazwisko, kl.nazwa_klubu from public.trenerzy tr inner join public.kluby kl on tr.id_klubu=kl.id_klubu order by tr.nazwisko asc, tr.imie asc")
    z=cur.fetchall()
    cur.close()
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
        club=(form.club).data
        
        cur=conn.cursor()
        cur.execute('select * from trenerzy where pesel=%s::numeric',[pesel])
        if ((cur.rowcount>0)):
            response="Trener o podanym peselu już istnieje"
        else:
            cur.execute('call dodaj_trenera(%s::varchar,%s::varchar,%s::numeric,%s::varchar,%s::varchar,%s::varchar,%s,%s,%s::varchar)',[name,surname,pesel,street,post_code,town,house_num,apt_num,club])
            conn.commit()
            cur.execute('select * from trenerzy where pesel=%s::numeric',[pesel])
            if (cur.rowcount>0):
                response=f"Dodano Trenera {name} {surname}"
            else:
                response="Niepowodzenie"
        cur.close()
        
    return render_template('trenerzy.html',form=form,response=response, value=z)


@app.route('/add_zawody',methods=['GET','POST'])
def add_zawody():
    cur=conn.cursor()
    cur.execute("Select zw.data_zawodow, zw.nazwa, ob.nazwa from public.zawody zw inner join public.obiekty ob on zw.id_obiektu=ob.id_obiektu order by zw.data_zawodow desc")
    z=cur.fetchall()
    cur.close()

    form=AddZawody()
    
    if form.validate_on_submit():
        zawody=(form.name).data
        
        location=(form.choose_location).data
        date=(form.date).data
        choices=(form.mul).data
        result=[]
        cur=conn.cursor()
        cur.execute('insert into zawody(nazwa,data_zawodow,id_obiektu) values(%s,%s,%s) ',[zawody,date,location])

        for data in choices:
            cur.execute('insert into zawody_konkurencje(id_zawodow,id_konkurencji) values((select id_zawodow from zawody where data_zawodow=%s and id_obiektu=%s and nazwa=%s),%s)',[date,location,zawody, data])
            
        conn.commit()
        cur.close()
        
    return render_template('zawody.html',form=form, value=z)

@app.route('/wyniki_zawodnika',methods=['GET','POST'])
def wyniki_zawodnika():
    form=ChooseSwimmer()
    val=["",""]
    
    
    if form.validate_on_submit():
        zawodnik=(form.player).data
        cur =conn.cursor()
        cur.execute('select * from nazwiska_wyniki where id_zawodnika=%s;',[zawodnik])
        val=cur.fetchall()
        cur.close()
        
    return render_template('wyniki_zawodnik.html',form=form,value=val)

@app.route('/wyniki_zawodow',methods=['GET','POST'])
def wyniki_zawodow():
    form=ChooseZawody()
    val=["",""]
    if form.validate_on_submit():
        zawody=(form.zawody).data
        konkurencja=(form.konkurencja).data
        plec=(form.plec).data
        cur=conn.cursor()
        print(konkurencja, plec, zawody)
        cur.execute(  " select * from wyniki_zawody where id_zawodow =%s AND plec = %s AND id_konkurencji =%s;",[zawody, plec, konkurencja])
        val=cur.fetchall()
        cur.close()
    return render_template('wyniki_zawody.html',form=form,value=val)

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
    form1.konkurencja.choices=session['choic']
    
    if form1.validate and form1.submit1.data:
                cursor=conn.cursor()
                id=session['id']
                cursor.execute("Insert into wyniki(id_konkurencji,id_zawodow,id_zawodnika,czas) values(%s,%s,%s,%s)",[(form1.konkurencja).data,id,(form1.zawodnik).data,(form1.czas).data])
                conn.commit()
                cursor.close()
    return render_template("add_zawodnik_form1.html",form=form1)

@app.route('/grupy',methods=["POST","GET"])
def grupy():
    form =ChooseGroup()
    if form.validate_on_submit:
        None

if __name__=='__main__':
    nav.init_app(app)
    app.run()
