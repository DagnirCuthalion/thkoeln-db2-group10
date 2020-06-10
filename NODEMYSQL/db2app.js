const express = require('express');
const mysql = require('mysql');
const http = require('http');
const bodyParser = require('body-parser');
const app = express()

app.use(bodyParser.urlencoded({ extended: true }));

app.set('view engine', 'ejs');

//For Dateformat
var dateFormat=require('dateformat');


//Import all related JavaScript and CSS files to inject in our APP
app.use('/js',express.static(__dirname + '/node_modules/bootstrap/dist/js'))
app.use('/js',express.static(__dirname + '/node_modules/tether/dist/js'))
app.use('/js',express.static(__dirname + '/node_modules/jquery/dist'))
app.use('/css',express.static(__dirname + '/node_modules/bootstrap/dist/css'))

//Create connection
const db = mysql.createConnection({
    host        : 'localhost',
    user        : 'root',
    database    : 'db2_test',
});

//Global site title and base url
const siteTitle = "DB2-App";
const baseURL ="http://localhost:3000/"


//Connect
db.connect((err)=>{
    if(err){
        throw err;
    }
    console.log('MySql Connected..');
});



app.listen('3000', () =>{
    console.log('Server started on port 3000');
});


//Get Person
app.get('/person/add',(req,res)=>{

    res.render('pages/add-event.ejs',{
        siteTitle : siteTitle,
        pageTitle: "Add Person",
        items : '' 
    });
});



//Insert sample data
//Post Person
app.post('/person/add',(req,res)=>{

    var query =     "INSERT INTO `person` (person_person_id,labor_id,nachname,vorname,geburtsdatum) VALUES ("
        query +=    " '"+req.body.person_person_id+"',";
        query +=    " '"+req.body.labor_id+"',";
        query +=    " '"+req.body.nachname+"',";
        query +=    " '"+req.body.vorname+"',";
        query +=    " '"+dateFormat(req.body.geburtsdatum,"yyyy-mm-dd")+"')";
    
    db.query(query,(err,result)=>{
        res.redirect("/person");
    });
});


//Update Person
app.get('/person/edit',(req,res)=>{

    db.query("SELECT * FROM person WHERE person_person_id = '"+ req.params.person_person_id + "'", (err,res)=>{

        res.render('pages/edit-person',{
            siteTitle : siteTitle,
            pageTitle : "Editing Person : " + result[0].vorname + result[0].nachname,
            item : result
        });

        if(err)throw err;
        console.log(result);
    });
});


//Show Persons
app.get('/person',(req,res)=>{

    db.query("SELECT * FROM person", (err,result)=>{
        res.render('pages/index',{
            siteTitle : siteTitle,
            pageTitle: "Person List",
            items : result 
        });
    })
});

//Show Labore
app.get('/labor',(req,res)=>{

    db.query("SELECT * FROM labor", (err,result)=>{
        res.render('pages/index',{
            siteTitle : siteTitle,
            pageTitle: "Labor List",
            items : result 
        });
    })
});

//Add Labor
app.get('/labor/add',(req,res)=>{

    res.render('pages/add-event.ejs',{
        siteTitle : siteTitle,
        pageTitle: "Add Labor",
        items : '' 
    });
});

//Insert sample data
//Post Labor
app.post('/labor/add',(req,res)=>{

    var query =     "INSERT INTO `labor` (labor_id,labor_name) VALUES ("
        query +=    " '"+req.body.labor_id+"',";
        query +=    " '"+req.body.labor_name+"')";
    
    db.query(query,(err,result)=>{
        res.redirect("/labor");
    });
});

//Update Labor
app.get('/updatelabor/:id',(req,res)=>{
    let sql = `UPDATE labor SET labor_id = '${req.body.labor_id}', labor_name = '${req.body.labor_name}' WHERE labor_id = ${req.params.id}`;
    let query = db.query(sql, (err,result)=>{
        if(err)throw err;
        console.log(result);
        res.send('Labor updated..');
    });
});