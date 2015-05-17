# systemInformation
A set of scripts that collate information about systems in an environment, and some html and js files to display the information in a useful format.


The scripts that collect information make a number of assumptions about the organisation of both the physical systems and technology choices in the environment.  Additionally, the collection scripts and display format incorporate a number of assumptions about the owning organisation.  These should be relatively configurable, and are detailed later.

The front end files can be used entirely separately to the collection scripts, provided that the data collected from your organisation can be assembled into a javascript file of the following format:

```
var systems = {
	"servers":	[
  {
    "name": "xxx",
    "ipAddr": "10.10.10.10",
    "state": "running",     // or "shut"
    "cpus": "96",
    "maxMem": "33325056",
    "usedMem": "33325031",
    "owner": "email1@domain.com;email2@domain.com",
    "type": "Physical",
    "os": "xxx",
    "usage": "a description of the system",
    "envId": "infservers",    // an assumption is that subsets of systems work together in environments
    "project": "infrastructure",  // an assumption is that systems are paid for or assigned to projects (or departments)
    "notes": "a note"
    "vms": [
            {
              "name": "vmxxx",
              "ipAddr": "10.10.11.11",
              "state": "running",
              "cpus": "20",
              "maxMem": "10240",
              "usedMem": "10240",
              "owner": "email1@domain.com;email2@domain.com",
              "type": "kvm",
              "os": "xxx",
              "usage": "a description of the system",
              "envId": "uniqId0001",
              "project": "xxx",
              "notes": "a note",
              },
              { ...  more vms ... },
              { ...  more vms ... },
           ],
  },
  { ... more servers ... },
  { ... more servers ... },
]}
```

The frontend files can then format the information with some nice d3 goodness to create an interactive pie chart such as this one:

![Screenshot of example pie chart](/img/Screenshot%20from%202015-05-16%2018%3A53%3A24.png?raw=true "Example pie chart")

The pie chart can be dynamically altered by selecting and deselecting operating systems, subnet, project, etc.

![Screenshot of dynamically altered pie chart](/img/Screenshot%20from%202015-05-16%2018:54:09.png?raw=true "Modified pie chart")

The pie chart also comes complete with tooltips.



For more information check out: http://philipharries.github.io/systemInformation/

An interactive demo populated with example data can be found here:  http://philipharries.github.io/systemInformation/web/1.0/usageByProject.html
