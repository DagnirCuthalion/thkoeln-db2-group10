const express = require('express');
const mysql = require('mysql');
const http = require('http');
const bodyParser = require('body-parser');
const app = express()

app.use(bodyParser.urlencoded({ extended: true }));

app.set('view engine', 'ejs');

//For Dateformat
var dateFormat = require('dateformat');
const { SSL_OP_EPHEMERAL_RSA } = require('constants');


//Import all related JavaScript and CSS files to inject in our APP
app.use('/js', express.static(__dirname + '/node_modules/bootstrap/dist/js'))
app.use('/js', express.static(__dirname + '/node_modules/tether/dist/js'))
app.use('/js', express.static(__dirname + '/node_modules/jquery/dist'))
app.use('/css', express.static(__dirname + '/node_modules/bootstrap/dist/css'))

//Create connection
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    database: 'db2_test',
});

//Global site title and base url
const siteTitle = "DB2-App";
const baseURL = "http://localhost:3000/"


//Connect with mysqldb
db.connect((err) => {
    if (err) {
        throw err;
    }
    console.log('MySql Connected..');
});

//listen for connection (per browser)
app.listen('3000', () => {
    console.log('Server started on port 3000');
});

//Get Person
//that comment makes no sense - i might have destroyed something here... anyway, propably not needed anymore, dynamicadd does this
app.get('/person/add', (req, res) => {

    res.render('pages/add-event.ejs', {
        siteTitle: siteTitle,
        pageTitle: "Add Person",
        items: ''
    });
});



//Insert sample data
//Post Person, propably not needed anymore, dynamicadd does this
app.post('/person/add', (req, res) => {

    var query = "INSERT INTO `person` (person_person_id,labor_id,nachname,vorname,geburtsdatum) VALUES ("
    query += " '" + req.body.person_person_id + "',";
    query += " '" + req.body.labor_id + "',";
    query += " '" + req.body.nachname + "',";
    query += " '" + req.body.vorname + "',";
    query += " '" + dateFormat(req.body.geburtsdatum, "yyyy-mm-dd") + "')";

    db.query(query, (err, result) => {
        res.redirect("/person");
    });
});


//Update Person
app.get('/person/edit', (req, res) => {

    db.query("SELECT * FROM person WHERE person_person_id = '" + req.params.person_person_id + "'", (err, res) => {

        res.render('pages/edit-person', {
            siteTitle: siteTitle,
            pageTitle: "Editing Person : " + result[0].vorname + result[0].nachname,
            item: result
        });

        if (err) throw err;
        console.log(result);
    });
});


//Show Persons, propably not needed anymore, getdynamic does this
app.get('/person', (req, res) => {

    db.query("SELECT * FROM person", (err, result) => {
        res.render('pages/index', {
            siteTitle: siteTitle,
            pageTitle: "Person List",
            items: result
        });
    })
});

//Show Labore, propably not needed anymore, getdynamic does this
app.get('/labor', (req, res) => {
    console.log('getting labor');
    var dynIn = generateDynIn('labor', '/dynamic').then(dynIn => {
        db.query("SELECT * FROM labor", (err, result) => {
            res.render('pages/get-dynamic.ejs', {
                siteTitle: siteTitle,
                pageTitle: "Labor List",
                dynIn
            });
            //console.log(result);
        })
    });
});

//Post Labor
//propably not needed anymore, dynamicadd does this
app.post('/labor/add', (req, res) => {
    //console.log('posting laboradd');
    var query = "INSERT INTO `labor` (labor_id,labor_name) VALUES ("
    query += " '" + req.body.labor_id + "',";
    query += " '" + req.body.labor_name + "')";
    //console.log('post laboradd query: ' + query);
    db.query(query, (err, result) => {
        if (err) res.send(err);
        res.redirect("/labor");
    });
});

//generate form for updating
app.get('/labor/edit/:id', (req, res) => {
    id = req.params.id - 1; //autoincrement starts with 1, array with 0, hence the subtraction
    dynIn = generateDynIn('labor', "http://localhost:3000/labor/update/" + id).then(dynIn => {
        //console.log(dynIn);
        //console.log(dynIn.tablename);
        res.render('pages/update-form-dynamic', {
            siteTitle: siteTitle,
            pageTitle: "hardcoded_Page Title",
            dynIn,
            id
        });
    });
})
//Update Labor
app.post('/labor/update/:id', (req, res) => {
    console.log('id of url: ' + req.params.id);
    req.params.id = (parseInt(req.params.id)+1).toString();
    console.log('id of url before update: ' + req.params.id);
    let sql = `UPDATE labor SET labor_id = '${req.body.labor_id}', labor_name = '${req.body.labor_name}' WHERE labor_id = ${req.params.id}`;
    let query = db.query(sql, (err, result) => {
        if (err) res.send(err);
        console.log('result of updatequery: ' + result);
        res.redirect('/labor');
    });
});

//deleting labor by param id
app.get('/labor/delete/:id', (req, res) => {
    let sql = `DELETE FROM labor WHERE labor_id = ${req.params.id}`;
    let query = db.query(sql, (err, result) => {
        if (err) res.send(err);
        console.log('result of deletequery: ' + result);
        res.redirect('/labor');
    });
})

app.get('/berechtigen', (req,res) =>
{
    console.log('starting berechtigen')
    res.render('pages/berechtigen_proc_form.ejs', {
        siteTitle: siteTitle,
        pageTitle: "hardcoded_Page Title",
    });
})

app.get('/berechtigung/delete/:id', (req, res) => {
    let sql = `DELETE FROM berechtigung WHERE person_id = ${req.params.id}`;
    let query = db.query(sql, (err, result) => {
        if (err) res.send(err);
        console.log('result of deletequery: ' + result);
        res.redirect('/dynamic/get/berechtigung');
    });
})

app.post('/berechtigen_proc', (req,res) =>
{
    console.log('starting berechtigen_proc')
    v = new Date(req.body.berechtigt_von);
    req.body.berechtigt_von = v.getFullYear()+'-0'+v.getMonth()+'-0'+v.getDay()+' 0'+v.getHours()+':0'+v.getMinutes()+':0'+v.getSeconds()
    v = new Date(req.body.berechtigt_bis); //let's just hope those exist, i'm lazy
    req.body.berechtigt_bis = v.getFullYear()+'-0'+v.getMonth()+'-0'+v.getDay()+' 0'+v.getHours()+':0'+v.getMinutes()+':0'+v.getSeconds()
    var query = "CALL `db2_test`.`proc_add_berechtigung`("; //starting to build a procedure call query
    //console.log('query tabname: '+query);
    //console.log(req.body);
    var valueArray = Object.values(JSON.parse(JSON.stringify(req.body))); //iterable array of the values of the last form
    valueArray.pop() //no need for tablename
    valueArray.forEach(function (v) {
        if(v.length==24)
        {
            //console.log(v)
            //v= v.getFullYear()+'-'+v.getMonth()+'-'+v.getDay()+' '+v.getHours()+':'+v.getMinutes()+':'+v.getSeconds()
            console.log(v)
            query += "'"+v +"'"+ ',';
        }
        else
            query += "'"+v+"'" + ','; //need to pass strings in " " to let mysql accept them
        //console.log(v.length)
        
    })
    query = query.slice(0,-1); //we do not want the last ',' so we slice it off
    query += ")"; //wohoo, query is finished
    console.log('finished query: '+query);
    db.query(query, (err, result) => { //executing query
        if(err) res.send(err); //errors are displayed in browser
        res.body = {tablename:'berechtigung'}
        console.log('set res body')
        console.log('redirecting to dynamicget')
        res.redirect("/dynamic/get/berechtigung"); //if no error we go back to the get page of the table
    });
})

//starting point for dynamic stuff, placeholder
app.get('/test', (req, res) => {
    res.render('pages/test', {
        siteTitle: siteTitle,
        pageTitle: "View Dynamic"
    });
});

//class containing all data needed for th dynamic pages
class DynamicInput {

    constructor(arr, tablename, action) {
        this.arr = arr;
        this.tablename = tablename;
        this.action = action;
    }
}

//generate add form for table passed in body.tablename
app.all('/dynamic', (req, res) => {
    console.log('starting dynamic');
    if(typeof(req.body.tablename)=='undefined')
        req.body.tablename="berechtigung" //just for getting it to work during the 3.ms
    var action = req.body.action
    if (typeof (action) == 'undefined') {
        console.log('>>req.body.action was not defined!! used standard<<')
        action = "http://localhost:3000/dynamic/add";
    }
    console.log('action: ' + action);
    var dynIn = generateDynIn(req.body.tablename, action).then(dynIn => {

        //console.log('hoping for dynin');
        console.log('dynintype: ' + typeof (dynIn));
        console.log('postdynamic tablename: ' + req.body.tablename);
        //console.log('action: ' + action);
        //dynIn.arr[1].forEach(function (e) { console.log(e) });


        console.log('dynIn.arr[0]: '+dynIn.arr[0])
        //dynIn.arr.forEach(function(e){console.log('e: '+e)});
        //console.log('action: ' + dynIn.action);

        console.log('should be rendering form now');
        res.render('pages/add-form-dynamic.ejs', {
            siteTitle: siteTitle,
            pageTitle: "hardcoded_Page Title",
            dynIn
        });
    });
});

//this shall be the main page, empty for now
app.get('/', (req, res) => {
    res.render('pages/main',
        {
            siteTitle: siteTitle,
            pageTitle: "hardcoded_Main"
        }
    )
})

//performing insert query based on passed form data
app.post('/dynamic/add', (req, res) => {
    console.log('starting dynamicadd');
    //console.log('tabname : '+req.body.tablename);
    
    if(req.body.geburtsdatum) //date passed as string isnt accepted by mysql, so we need to pass a Date
    {
        req.body.geburtsdatum = new Date(req.body.geburtsdatum);
        //console.log(req.body.geburtsdatum);
    }
    dynIn = generateDynIn(req.body.tablename, "http://localhost:3000/" + req.body.tablename); //we expect a tablename in body, redirecting to the get page of the table after executing the add. todo: redirect to dynamic get 
    var query = "INSERT INTO "+req.body.tablename +" ("; //starting to build a insert query on the passed table
    //console.log('query tabname: '+query);
    //console.log(req.body);
    var keyArray = Object.keys(JSON.parse(JSON.stringify(req.body))); //need something iterable, so we get the keys of the body into a array
    keyArray.pop(); //it contains a tablename which we do not want to be inserted
    keyArray.forEach(function (k) {
        //console.log('key: '+k);
        query += k + ',' //looping through the remaining keys we add those to our columns in the query
        //console.log('query in first for: '+query);
    });
    query = query.slice(0,-1); //we do not want the last ',' so we slice it off
    //console.log('query fieldnames: '+query);
    query += ") VALUES ("; //next come the values
    var valueArray = Object.values(JSON.parse(JSON.stringify(req.body))); //iterable array of the values of the last form
    valueArray.pop(); //dont want hte tablename here either
    valueArray.forEach(function (v) {
        query += '"'+v+'"' + ','; //need to pass strings in " " to let mysql accept them
    })
    query = query.slice(0,-1); //we do not want the last ',' so we slice it off
    //console.log('query values: '+query);
    query += ")"; //wohoo, query is finished
    //console.log('finished insertquery: '+query);
    db.query(query, (err, result) => { //executing query
        if(err) res.send(err); //errors are displayed in browser
        res.redirect("/"+req.body.tablename); //if no error we go back to the get page of the table
        //console.log('redirected from dynadd')
    });
});

app.get('/dynamic/get/:id', (req,res) =>
{
    console.log('getting dynamic');
    console.log('id: '+req.params.id)
    var dynIn = generateDynIn(req.params.id, '/dynamic').then(dynIn => {
        db.query("SELECT * FROM "+dynIn.tablename, (err, result) => {
            res.render('pages/get-dynamic.ejs', {
                siteTitle: siteTitle,
                pageTitle: "Table List",
                dynIn
            });
            //console.log(result);
        })
    });
})

//needed for db calls in functions
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

//returns data for passed table in an instance of DynamicInput
async function generateDynIn(tablename, action) {
    console.log('starting gendynin');
    var dynIn; //this is what we want to return
    db.query("SELECT * FROM " + tablename, (err, result) => { //getting all data from the specified table
        if (err) throw err; //errors are shown in console
        //console.log('result: ' + result);
        //console.log('err: ' + err);
        var resultArray = Object.values(JSON.parse(JSON.stringify(result))); //as above we need something iterable, so we convert the selected
        //console.log('resArr: ' + resultArray);
        var numberOfAttributes; //how long does the inner array need to be
        if (typeof (resultArray[1]) == 'undefined') //if table is empty
            numberOfAttributes = 0; //we need no inner array
        else
            numberOfAttributes = resultArray[1].size; //else we need it to be of the size equal to the n of columns
        dynIn = new DynamicInput(Array(resultArray.size), tablename, action); //we initialize dynIn with an Array big enough to fit all rows and the params of this function
        //console.log('initialized dynin tabname: ' + dynIn.tablename);
        var j = 0;
        resultArray.forEach(function (v) {
            var values = Array(numberOfAttributes); 
            //console.log('v: ' + v);
            i = 0;
            for (var key in v) { //for each columnname
                //console.log('v.key: ' + key);
                if (Object.prototype.hasOwnProperty.call(v, key)) {
                    var val = v[key];
                    // use val
                    //console.log('v.val: ' + val);
                    values[i++] = { name: key, value: val };
                }
            }
            dynIn.arr[j++] = values;
            //console.log('foreach dynin tabname: ' + dynIn.tablename);
        });
        //console.log('query dynin tabname: ' + dynIn.tablename);
    });
    //console.log('going to sleep');
    await sleep(50);
    //console.log('waking up');
    //console.log('function dynin tabname: ' + dynIn.tablename);
    return dynIn
}