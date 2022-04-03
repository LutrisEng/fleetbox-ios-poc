---
sidebar_position: 1
---

# Vehicle

![The screen seen immediately after selecting a vehicle in Fleetbox](landing.jpg)

Vehicles are the core of Fleetbox - nearly everything you do will be attached to one. There intentionally isn't a strict definition of what a vehicle is or what the difference between two vehicles is. Even if your vehicle becomes a [Ship of Theseus](https://en.wikipedia.org/wiki/Ship_of_Theseus), you can still keep using the same Fleetbox vehicle and just tweak its attributes as you go.

## Vehicle Details

![A Fleetbox vehicle's details list](details.jpg)

In a vehicle's details, you can customize many properties and see a few status gauges:

### Name

Under "Name," you can set a display name for your vehicle.

### VIN

Under "VIN," you can save the VIN (or Vehicle Identification Number) of your vehicle. You can also press a button to decode that VIN and automatically fill the "Year," "Make," and "Model" fields.

### Year, Make, and Model

Under "Year," "Make," and "Model" you can save the, well, year, make, and model of your vehicle.

### License plate

The "License plate" property is automatically filled with the license plate number you specified in your last "Registered with state" [Line Item](/docs/concepts/lineitem). If you don't have a "Registered with state" Line Item, this property will be missing.

### Tires

The "Tires" property is automatically filled with the tire set you specified in your last "Tire set mounted" [Line Item](/docs/concepts/lineitem). If you don't have a "Tire set mounted" Line Item, or you have since added a "Tire set dismounted" Line Item, this property will be missing.

### Break-in period

Under "Break-in period," you can track the break-in period of your vehicle. By default, this is set to 1,000 miles, however you can customize it to whatever threshold you (or your vehicle's manufacturer) prefer(s).

### Tire break-in period

Under "Tire break-in period," you can track the break-in period of your tire set. This refers to the same tire set as the "Tires" property. By default, this is set to 500 miles, however you can customize it to whatever threshold you (or your tires' manufacturer) prefer(s).

### Odometer

Under "Odometer," you can see an estimated current odometer reading, and also view an odometer details screen.

## Odometer details

By tapping the "Odometer" property under a vehicle's details, you can access the odometer details screen.

![A screenshot of the Fleetbox odometer details screen](odometer.jpg)

### Last reading

Under "Last reading," you can see the mile count of this vehicle's last [Odometer Reading](/docs/concepts/odometerreading) and how long ago that reading was made.

### Est. distance per year

Under "Est. distance per year," you can set your estimate for how many miles this vehicle travels per year. If blank, this defaults to an estimate made by Fleetbox based on previous [Odometer Readings](/docs/concepts/odometerreading).

### Est. current reading

Under "Est. current reading," you can see an estimate of what your odometer may currently read. This estimate is made based on the "Est. distance per year."

### View history

Under "View history," you can view a history of every [Odometer Reading](/docs/concepts/odometerreading) on this vehicle and every [Log Item](/docs/concepts/logitem) which contains an Odometer Reading.

### Part odometers

Under "Part odometers," you can see the age of many components of the vehicle in both miles and time. These "part odometers" are based on your line items - for instance an "Engine oil changed" line item will reset the part odometer for your engine oil.

## Warranties

![A screenshot of a Fleetbox vehicle's warranties section](warranties.jpg)

## Attachments

![A screenshot of a Fleetbox vehicle's attachments section](attachments.jpg)

## Maintenance log

![A screenshot of a Fleetbox vehicle's maintenance log](log.jpg)