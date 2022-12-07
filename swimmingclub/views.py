import json
import os
from django.http import HttpResponse
from django.contrib.auth.models import User
from django.template import loader
from django.shortcuts import render
from django.contrib.auth import authenticate,login,logout
from django.template import RequestContext
from django.views.decorators.csrf import csrf_exempt
# def add_user(request):
    
#     return HttpResponse(f"added user{user.email}")
@csrf_exempt
def login_s(request):
        json_dat=json.loads(request.body)
        passwd=json_dat['password']
        usrnm=json_dat['username']
        user=authenticate(username=usrnm,password=passwd) 
        login(request,user)
        if user is not None:
            return HttpResponse("success "+user.get_username())
        else:
            return HttpResponse("bad_cred")
def show_user(request):
    return HttpResponse(request.user.email+"good")
def index(request):
    template=loader.get_template('home.html')
    return HttpResponse(template.render())
def create_account(request):
    template =loader.get_template('create_account.html')
    return HttpResponse(template.render())
