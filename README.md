# `TrackingAudit`
### Overview
The `TrackingAudit` class is responsible for scheduling and executing a job to track missing tracking numbers in sales records and send an email notification to the Tech Team if any are found.

### `TrackingAudit`
This class is a Salesforce Schedulable class. It's designed to regularly check for sales records that are missing tracking numbers and notify the Tech Team about any missing numbers it discovers.

## Class Methods Descriptions

### `TrackingAudit`
- **`execute(SchedulableContext sc)`**: This method is the entry point for the scheduled job. It queries sales records created in the last two weeks and checks for missing tracking numbers. If any records have missing tracking numbers, it sends an email notification to the Tech Team. The method doesn't return any value.

## How To Use
To use the `TrackingAudit` class, you need to schedule it within your Salesforce organization. The class implements the Schedulable interface, so it can be scheduled to run at specified times, such as once a day or every hour, depending on your organization's needs.

Here's an example of how you can schedule the `TrackingAudit` class to run:

```java
TrackingAudit ta = new TrackingAudit();
String cronExp = '0 0 0 * * ?'; // runs every day at midnight
System.schedule('TrackingAuditJob', cronExp, ta);
