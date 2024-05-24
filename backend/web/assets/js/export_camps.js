function clearDate() {
    document.getElementById("campDate").value = "";
}

let camps = [];

function loadCamps() {
    let campLocation = document.getElementById("campLocation").options[document.getElementById("campLocation").selectedIndex].text;
    let campDate = document.getElementById("campDate").value;
    let campFacility = document.getElementById("campFacility").value;
    let campNamePartial = document.getElementById("campName").value;

    if (campLocation === document.getElementById("campLocation").options[0].value) {
        campLocation = "";
    }

    let output = document.getElementById("campResults");
    output.innerHTML = "";
    camps.forEach((camp) => {
        let campName = camp.camp_name;
        let facility = camp.facility_name;
        let campDescription = camp.camp_description;
        let supervisorNames = camp.supervisor_names;
        let directorNames = camp.director_names;
        let camperCount = camp.camper_count;
        let room = camp.camp_room;
        let location = camp.location_name;
        let start_date = camp.start_date;
        let end_date = camp.end_date;
        let campID = camp.camp_id

        if (campLocation !== "" && campLocation.toLowerCase().includes(location.toLowerCase()) === false) {
            // console.log("location" + campName)
            return;
        }

        if (campDate !== "" && (campDate < start_date || campDate > end_date)) {
            // console.log("date" + campName)
            return;
        }

        if (campFacility !== "" && facility.toLowerCase().includes(campFacility.toLowerCase()) === false) {
            // console.log("facility" + campName)
            return;
        }

        if (campNamePartial !== "" && campName.toLowerCase().includes(campNamePartial.toLowerCase()) === false) {
            // console.log("name" + campName)
            return;
        }

        let supervisorName = "";
        for (let i = 0; i < supervisorNames.length; i++) {
            supervisorName += supervisorNames[i];
            if (i < supervisorNames.length - 1) {
                supervisorName += ", ";
            }
        }

        let directorName = "";
        for (let i = 0; i < directorNames.length; i++) {
            directorName += directorNames[i];
            if (i < directorNames.length - 1) {
                directorName += ", ";
            }
        }

        let templateOutput = `
        <div class="col-sm-12">
            <div class="alert alert-secondary" role="alert">
<!--                <h4>${campName} @ ${facility} in ${room}</h4>-->
                <h4>${campName} @ ${facility}</h4>
                <p>
                    ${campDescription}
                </p>
                <hr />
                <div class="row">
                    <div class="col-sm-10">
                        <p>
                            ${start_date} to ${end_date}
                           <!-- <br>Camp Supervisor(s): ${supervisorName}
                            <br>Camp Director(s): ${directorName} -->
                            <br>Campers: ${camperCount}
                            <br>Location: ${location}
                        </p>
                    </div>
                    <div class="col-sm-2 align-self-end">
                        <button type="button" class="btn btn-primary w-100 text-white" onclick="fetchCSV(${campID}, '${campName}')">
                            Export
                        </button>
                    </div>
                </div>
            </div>
        </div>
        `

        output.innerHTML += templateOutput;
    });
}

function locationParser(location) {
    return encodeURIComponent(location.replace(/ /g, "_").toLowerCase());
}

function updateFacilities() {
    // when the location is changed, update the facilities
    let location = document.getElementById("campLocation").options[document.getElementById("campLocation").selectedIndex].text;
    location = locationParser(location);
    let facilitySelect = document.getElementById("facilities");
    let facilityOptions = facilitySelect.options;
    for (let i = 0; i < facilityOptions.length; i++) {
        let facility = facilityOptions[i];
        if (facility.classList.contains(location + "_location_facility")) {
            //remove disabled
            facility.disabled = false;
        } else {
            //add disabled
            facility.disabled = true;
        }
        if (document.getElementById("campLocation").selectedIndex === 0) {
            facility.disabled = false;
        }
    }
}
let facilitySelect = document.getElementById("campLocation");
facilitySelect.addEventListener("change", updateFacilities);

setup()
function setup() {
    // Location setup
    let locationFetchUrl = "/api/admin/fetch_locations";
    let xhr = new XMLHttpRequest();
    xhr.open("GET", locationFetchUrl, true);
    xhr.setRequestHeader("Content-Type", "application/json");
    xhr.onreadystatechange = function () {
        if (xhr.readyState === 4 && xhr.status === 200) {
            let locations = JSON.parse(xhr.responseText);
            let locationSelect = document.getElementById("campLocation");
            locations.forEach((location) => {
                let option = document.createElement("option");
                option.text = location.location_name;
                option.value = location.location_id;
                locationSelect.add(option);
            });
        }
    };
    xhr.send();
    

    //Facility setup
    let facilityFetchUrl = "/api/admin/fetch_facilities";
    let facilityXhr = new XMLHttpRequest();
    facilityXhr.open("GET", facilityFetchUrl, true);
    facilityXhr.setRequestHeader("Content-Type", "application/json");
    facilityXhr.onreadystatechange = function () {
        if (facilityXhr.readyState === 4 && facilityXhr.status === 200) {
            let facilities = JSON.parse(facilityXhr.responseText);
            let facilitySelect = document.getElementById("facilities");
            facilities.forEach((facility) => {
                let option = document.createElement("option");
                option.value = facility.facility_name;
                option.classList.add(locationParser(facility.location_name)+"_location_facility")
                facilitySelect.appendChild(option);
            });
        }
    };
    facilityXhr.send();


    //Fetch camps
    let campFetchUrl = "/api/admin/fetch_camps";
    let campXhr = new XMLHttpRequest();
    campXhr.open("GET", campFetchUrl, true);
    campXhr.setRequestHeader("Content-Type", "application/json");
    campXhr.onreadystatechange = function () {
        if (campXhr.readyState === 4 && campXhr.status === 200) {
            camps = JSON.parse(campXhr.responseText);
            loadCamps();
        }
    }
    campXhr.send();


    let url = "/api/admin/user_info";
    let userXHR = new XMLHttpRequest();
    userXHR.open("GET", url, true);
    userXHR.setRequestHeader("Content-Type", "application/json");
    userXHR.onreadystatechange = function () {
        if (userXHR.readyState === 4 && userXHR.status === 200) {
            let userInfo = JSON.parse(userXHR.responseText);
            let user1 = document.getElementById("user1");
            user1.innerHTML = userInfo.user;
            let user2 = document.getElementById("user2");
            user2.innerHTML = userInfo.user;
        }
    };
    userXHR.send();

} // TODO BUG FIX CUS THERES GONNA BE MANY BUGS


// TODO maybe on type load camps

function fetchCSV(campID, camp_name) {
    // console.log("fetching csv for camp " + campID);
    let csvFetchUrl = `/api/admin/fetch_csv/${campID}`;
    let xmlHttpRequest = new XMLHttpRequest();
    xmlHttpRequest.open("GET", csvFetchUrl, true);
    xmlHttpRequest.setRequestHeader("Content-Type", "application/json");
    xmlHttpRequest.responseType = 'blob';
    xmlHttpRequest.onreadystatechange = function () {
        if (xmlHttpRequest.readyState === 4 && xmlHttpRequest.status === 200) {
            //download passed file
            let a = document.createElement('a');
            a.href = window.URL.createObjectURL(xmlHttpRequest.response);
            a.download = camp_name + ".xlsx";
            a.style.display = 'none';
            document.body.appendChild(a);
            a.click();
            window.URL.revokeObjectURL(a.href);
        }
    }
    xmlHttpRequest.send();
}


// function getUser() {
//     let userFetchUrl = "/api/admin/user_info";
//     let userXhr = new XMLHttpRequest();
//     userXhr.open("GET", userFetchUrl, true);
//     userXhr.setRequestHeader("Content-Type", "application/json");
//     userXhr.onreadystatechange = function () {
//         if (userXhr.readyState === 4 && userXhr.status === 200) {
//             let user = JSON.parse(userXhr.responseText);
//             let userElement = document.getElementById("user1");
//             let userElement2 = document.getElementById("user2");
//             userElement.innerHTML = user;
//             userElement2.innerHTML = user;
//         }
//     }
// }
//onload get user
// getUser();