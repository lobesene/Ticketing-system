pragma solidity >=0.4.21 <0.6.0;

contract ticketingSystem{
    uint nextArtistId=1;
    uint nextVenueId=1;
    uint nextTicketId=1;
    uint nextConcertId=1;
    


    struct Artist{
        address owner;
        bytes32 name;
        uint artistCategory;
    }

    struct Venue{ 
        bytes32 name;
        uint capacity;
        uint standardComission;
        address owner;
    }

     struct Concert{
         uint artistId;
         uint venueId;
         bool validatedByVenue;
         bool validatedByArtist;
         bool validateConcert;
         uint concertDate;
         uint totalticketsold;
         uint totalMoneyCollected;
         address ticketMaker;
         uint price;

    }
     
     struct Ticket{  
         address owner;
         uint concertDate;
         bool isAvailable;
         uint artist;
         uint venueId;  
         uint concertId;
         
     }

    mapping(uint=>Artist) public artistsRegister;
    mapping(uint=>Venue) public venuesRegister;
    mapping(uint=>Concert) public concertsRegister;
    mapping(uint=>Ticket) public ticketsRegister;

    function createArtist(bytes32 artistName, uint artistCategory)public returns(bool){
        artistsRegister[nextArtistId].name=artistName;
        artistsRegister[nextArtistId].artistCategory=artistCategory;
        artistsRegister[nextArtistId].owner=msg.sender;
        nextArtistId=nextArtistId+1;
        return true;

    }

    function modifyArtist(uint ArtistId,bytes32 artistName,uint newCategory,address account)public returns(bool){
        require(artistsRegister[ArtistId].owner==msg.sender);
        artistsRegister[ArtistId
        ].name=artistName;
        artistsRegister[ArtistId
        ].artistCategory=newCategory;
        artistsRegister[ArtistId
        ].owner=account;
        return true;
    }

    function createVenue(bytes32 venueName,uint venueCapacity, uint comission)public{
        venuesRegister[nextVenueId].name=venueName;
        venuesRegister[nextVenueId].capacity=venueCapacity;
        venuesRegister[nextVenueId].standardComission=comission;
        venuesRegister[nextVenueId].owner=msg.sender;
        nextVenueId=nextVenueId+1;

    }

    function modifyVenue(uint VenueId,bytes32 venueName,uint capacity, uint commission, address account)public{
        require(venuesRegister[VenueId].owner==msg.sender);
        venuesRegister[VenueId].name=venueName;
        venuesRegister[VenueId].capacity=capacity;
        venuesRegister[VenueId].standardComission=commission;
        venuesRegister[VenueId].owner=account;

    }

    function createConcert(uint _artistId,uint VenueId,uint _concertDate,uint capacity )public{
        concertsRegister[nextConcertId].artistId=_artistId;
        concertsRegister[nextConcertId].concertDate=_concertDate;
        concertsRegister[nextConcertId].validatedByArtist=false;
        if(nextConcertId%2==0){
            concertsRegister[nextConcertId].validatedByArtist=true;     
        }
        concertsRegister[nextConcertId].validatedByVenue=false; 
      validateConcert(nextConcertId);
      nextConcertId=nextConcertId+1;
    }

    function validateConcert(uint _concertId) public{
    require(concertsRegister[_concertId].concertDate >= now);

    if (venuesRegister[concertsRegister[_concertId].venueId].owner == msg.sender){
        concertsRegister[_concertId].validatedByVenue = true;
    }

    if (artistsRegister[concertsRegister[_concertId].artistId].owner  == msg.sender){
        concertsRegister[_concertId].validatedByArtist = true;
    }}

    function emitTicket(uint _concertId, address _ticketOwner) public{
        require(msg.sender == concertsRegister[_concertId].ticketMaker);
        //ticketsRegister[nextTicketId].owner=_ticketOwner;
        //J'ai vu Kendji faire ça et c'est vachement pratique
        Concert storage concert = concertsRegister[_concertId];
        ticketsRegister[nextTicketId] = Ticket(_ticketOwner, concert.concertDate,true,concert.artistId, concert.venueId,_concertId);
        concertsRegister[_concertId].totalticketsold=concertsRegister[_concertId].totalticketsold+1;
        concertsRegister[_concertId].totalMoneyCollected= concertsRegister[_concertId].totalMoneyCollected+concertsRegister[_concertId].price;
        nextTicketId=nextTicketId+1; 
    }

    function emitArtist(uint _concertId, address _ticketOwner,uint _artistId)public{
        require(msg.sender == artistsRegister[_artistId].owner);
         emitTicket( _concertId,_ticketOwner);
    }

    function usetickets(uint _ticketId)public{
    require(msg.sender == ticketsRegister[_ticketId].owner);
    require(concertsRegister[ticketsRegister[_ticketId].concertId].validatedByVenue==true&&concertsRegister[ticketsRegister[_ticketId].concertId].validatedByArtist == true);
    ticketsRegister[_ticketId].owner=address(0);
    ticketsRegister[_ticketId].isAvailable = false;
    }

}