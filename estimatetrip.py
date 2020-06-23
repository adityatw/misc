# -*- coding: utf-8 -*-
"""
Created on Fri Jun 19 15:29:48 2020

@author: Aditya Wresniyandaka
"""

#### Create a subfolder relative to the location of this python code to store called 'static' to store your image
#### Update the path in line 25 myImagePath

import io
import os
import random
import matplotlib.pyplot as plt
from matplotlib.pyplot import figure
from matplotlib.backends.backend_agg import FigureCanvasAgg as FigureCanvas
from matplotlib.figure import Figure
from flask import Flask, request
import math

random.seed(1234)
B = 100000

app = Flask(__name__, static_url_path='/static')
app.config['SEND_FILE_MAX_AGE_DEFAULT'] = 0
myImagePath = 'c:/users/adity/Documents/MachineLearning/static/'

@app.route('/estimate', methods=['GET', 'POST']) #allow both GET and POST requests
def intake_form():
    if request.method == 'POST':  #this block is only entered when the form is submitted
        reservation_time = request.form.get('reservation_time')
        leaving = request.form['leaving']
        delayleaving = request.form['delayleaving']
        delaytraffic = request.form['delaytraffic']
        
        # A bit of input format check
        if reservation_time.find(":") == -1 or leaving.find(":") == -1 or int(delayleaving) >= 16 or int(delayleaving) <0 or int(delaytraffic) >= 31 or int(delaytraffic) <00 :
            return '''
                <h2>Incorrect data entered!</h2>
                '''
        
        def convertFromTime(x):
            thehour = int(x[0:x.find(":")])
            theminute = int(x[x.find(":")+1:])/60
            return thehour+theminute
        
        def convertToTime(x):
            thehour = math.floor(x)
            theminute = round((x-math.floor(x))*60)
            if theminute == 60:
                thehour = thehour + 1
                theminute = 00
            timestring = str(thehour)+ ":" + str(theminute).zfill(2)
            return(timestring)
            
        ## Monte Carlo simulation for a trip to a restaurant
        leaveOffice = convertFromTime(leaving)         #(17.5 means planning to leave office at 5:30 PM)
        leaveDeviation = int(delayleaving)/60      #(10 mins delay from the time leaving the office)
        carTrip = 30/60             #(30 mins drive duration)
        cartripDeviation = int(delaytraffic)/60    #(10 mins longer in the the drive duration)
        parking = 5/60              #(5 mins to park the car)
        reservationTime = convertFromTime(reservation_time)    #(reservation at 6:15 PM)
            
        arrivals = []
        for i in range (B):
            leaveTime = random.uniform(leaveOffice, leaveOffice+leaveDeviation)
            driveDuration = random.uniform(carTrip, carTrip+cartripDeviation)
            total =(leaveTime+driveDuration+parking)
            arrivals.append(total)
                
        onTime = sum(1 for i in arrivals if i<=reservationTime)
        arrivingOnTime = round((onTime/B) * 100,2)
        chancesMessage = str(arrivingOnTime) + "%"
        etaMessage =  convertToTime(min(arrivals))+ " and " + convertToTime(max(arrivals))
        print ("Chances of arriving on time: " + chancesMessage)
        print ("Estimated arrival time between: "  + etaMessage)
        
        if arrivingOnTime <= 70 :
            additionalMessage = ' -- Hurry up!'
        else :
            additionalMessage = ''
            
        def create_hist():
            if os.path.exists(myImagePath+'*.png'):
                os.remove(myImagePath+'*.png')
            else:
                print("The file does not exist")
            fig = Figure()
            figure(num=None, figsize=(12, 8), dpi=80, facecolor='w', edgecolor='k')
            arrivalstime = [convertToTime(x) for x in arrivals]
            plt.xticks(rotation=45)
            plt.xlabel("Possible arrival times. \nNote that the decimal is a fraction of 60 minutes, e.g. .25 is :15 and .5 is :30", fontsize = 'large')
            plt.hist(arrivals, bins=10, ec = 'white')
            plt.axvline(reservationTime, linewidth=4, color='r',label='Reservation Time at '+reservation_time)
            plt.legend(fontsize='large')
            plt.savefig(myImagePath+'TripHist.png')
            return fig
        
        fig = create_hist()
        output = io.BytesIO()
        FigureCanvas(fig).print_png(output)
    
    
        return '''
            <h2>Your reservation is at: {}</h2>
            <h2>You plan to leave at : {} but with an anticipated delay of {} minutes and a potential of {} minutes delay in traffic</h2>
            <h2>---------------------------------------</h2>
            <h3>Your chance of arriving early or on-time: {} {}</h3> 
            <h3>Your Estimated Time of Arrival is between : {}</h3>
            <br>
            <img src = 'static/TripHist.png'>
            '''.format(reservation_time,leaving,delayleaving,delaytraffic,chancesMessage, additionalMessage, etaMessage)

    
    return '''<form method="POST">
                  <h1>Estimate your chance of arriving early or on time ... Don't be late!</h1>
                  <h3>(Assumption: 30 minutes to drive and 5 minutes to park)</h3>
                  <h3>Reservation time (hh:mm, 24-hour format): <input type="text" name="reservation_time"></h3>
                  <h3>Leaving at (hh:mm, 24-hour format): <input type="text" name="leaving"></h3>
                  <h3>Potential delay in leaving on-time (in minutes, 0-15): <input type="text" name="delayleaving"></h3>
                  <h3>Potential delay in traffic (in minutes, 0-30): <input type="text" name="delaytraffic"></h3>
                  <br>
                  <input type="submit" value="Submit"><br>
              </form>'''
    
    
 # Launch the FlaskPy dev server
app.run(host="localhost", debug=True)
