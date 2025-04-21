# SQLManualHistory

This is an example of a very through audit process that can be implemented using just SQL. Triggers on the tables make a copy of any data that's changed for historical record and stored procedures ensure that the user info for the person making the change is captured. This is very useful for keeping and displaying a very detailed history of a record (see example screenshots).. but not so great for performance when working with large data sets.
