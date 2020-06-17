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
    //console.log('getting labor');
    db.query("SELECT * FROM labor", (err,result)=>{
        res.render('pages/get-dynamic.ejs',{
            siteTitle : siteTitle,
            pageTitle: "Labor List",
            items : result 
        });
        //console.log(result);
    })
});

//Insert sample data
//Post Labor
app.post('/labor/add',(req,res)=>{
    //console.log('posting laboradd');
    var query =     "INSERT INTO `labor` (labor_id,labor_name) VALUES ("
        query +=    " '"+req.body.labor_id+"',";
        query +=    " '"+req.body.labor_name+"')";
    //console.log('post laboradd query: ' + query);
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



app.get('/test',(req,res)=>{
    res.render('pages/test',{
        siteTitle : siteTitle,
        pageTitle: "View Dynamic"
    });
});


class DynamicInput {

    constructor(arr, tablename, action)
    {
        this.arr = arr;
        this.tablename = tablename;
        this.action = action;
    }
}

app.post('/dynamic',(req,res)=>{
    var dynIn = new DynamicInput(Array(0),'tablename_u_shall_not_see_this','action_u_shall_not_see_this');
    console.log('postdynamic tablename: '+req.body.tablename);
    db.query("SELECT * FROM "+req.body.tablename,(err,result)=>{
        //console.log('result: '+result);
        //console.log('err: '+err);
        var resultArray = Object.values(JSON.parse(JSON.stringify(result)));
        //console.log('resArr: ' + resultArray);
        var numberOfAttributes;
        if(typeof(resultArray[1])=='undefined')
            numberOfAttributes = 0;
        else
            numberOfAttributes=resultArray[1].size
        dynIn = new DynamicInput(Array(numberOfAttributes),req.body.tablename, req.body.action);
        resultArray.forEach(function(v)
        {
            //console.log('v: '+v);
            i=0;
            for (var key in v) {
                //console.log('v.key: '+key);
                if (Object.prototype.hasOwnProperty.call(v, key)) {
                    var val = v[key];
                    // use val
                    //console.log('v.val: '+val);
                    dynIn.arr[i++] = {name:key, value:val}
                }
            }
        })
        //dynIn.arr.forEach(function(e){console.log(e)});
        if(dynIn.action=='action_u_shall_not_see_this'||typeof(dynIn.action)=='undefined')
        {
            console.log('>>dynIn.action was not defined!!<<')
            dynIn.action="http://localhost:3000/"+req.body.tablename+'/add';
        }
            
        //console.log('dynIn.arr:')
        //dynIn.arr.forEach(function(e){console.log('e: '+e)});
        //console.log('action: ' + dynIn.action);

        console.log('should be rendering form now');
        res.render('pages/add-form-dynamic.ejs',{
        siteTitle : siteTitle,
        pageTitle: "hardcoded_Page Title",
        dynIn
        });
    });
});

app.get('/', (req,res)=>{
    res.render('pages/main',
        {
            siteTitle : siteTitle,
            pageTitle: "hardcoded_Main"
        }
    )
})

app.post('/dynamic/add',(req,res)=>{

    var query =     "INSERT INTO `<% req.body.tablename %>` (";
        console.log(req.body);
        //query -= ','
            
        query += ") VALUES (";
        
        //query -= ',';
        query += ")";
    
    db.query(query,(err,result)=>{
        res.redirect("/");
    });
});