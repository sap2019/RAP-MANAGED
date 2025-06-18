@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Approvel projection view'
@Metadata.ignorePropagatedAnnotations: true
@UI: {
  headerInfo: { typeName: 'Travel',
               typeNamePlural: 'Travels',
               title: { type: #STANDARD, value: 'TravelID' }
               } }
@Search.searchable: true
define root view entity Zc_TRAVEL_approver_1
  provider contract transactional_query
  as projection on zi_travel_techm_1

{
      @UI.facet: [ { id:              'Travel',
                               purpose:         #STANDARD,
                               type:            #IDENTIFICATION_REFERENCE,
                               label:           'Travel',
                               position:        10 } ,
                             { id:              'Booking',
                               purpose:         #STANDARD,
                               type:            #LINEITEM_REFERENCE,
                               label:           'Booking',
                               position:        20,
                               targetElement:   '_Booking'}]
      @UI: {
                lineItem:       [ { position: 10, importance: #HIGH } ],
                identification: [ { position: 10 } ] }
      @Search.defaultSearchElement: true
  key TravelId,
      @UI: {
                lineItem:       [ { position: 20, importance: #HIGH } ],
                identification: [ { position: 20 } ],
                selectionField: [ { position: 20 } ] }
      @Consumption.valueHelpDefinition: [ { entity : {name: '/DMO/I_Agency',
                                           element: 'AgencyID'  } } ]
      @ObjectModel.text.element: ['AgencyName']
      @Search.defaultSearchElement: true
      AgencyID,
      _Agency.Name       as AgencyName,
      @UI: {
           lineItem:       [ { position: 30, importance: #HIGH } ],
           identification: [ { position: 30 } ],
           selectionField: [ { position: 30 } ] }
      @Consumption.valueHelpDefinition: [ { entity : {name: '/DMO/I_Customer', element: 'CustomerID'  } } ]

      @ObjectModel.text.element: ['CustomerName']
      @Search.defaultSearchElement: true
      CustomerID,
      _Customer.LastName as CustomerName,
      @UI: {
          identification:[ { position: 40 } ] }
      BeginDate,
      @UI: {
        identification:[ { position: 41 } ] }
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      @UI: {
       lineItem:       [ { position: 42, importance: #MEDIUM } ],
       identification: [ { position: 42 } ] }

      BookingFee,
      @UI: {
       lineItem:       [ { position: 43, importance: #MEDIUM } ],
       identification: [ { position: 43, label: 'Total Price' } ] }
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      @Consumption.valueHelpDefinition: [ {entity: {name: 'I_Currency', element: 'Currency' } } ]

      CurrencyCode,
      @UI: {
          lineItem: [ { position: 45, importance: #MEDIUM } ],
          identification:[ { position: 45 } ] }
      Description,
      @UI: {
                 lineItem:       [ { position: 15, importance: #HIGH },
                                   { type: #FOR_ACTION, dataAction: 'acceptTravel', label: 'Accept Travel' },
                                   { type: #FOR_ACTION, dataAction: 'rejectTravel', label: 'Reject Travel' } ],
                 identification: [ { position: 15 },
                                   { type: #FOR_ACTION, dataAction: 'acceptTravel', label: 'Accept Travel' },
                                   { type: #FOR_ACTION, dataAction: 'rejectTravel', label: 'Reject Travel' } ] ,
                 textArrangement: #TEXT_ONLY,
                 selectionField: [ { position: 40 } ] }
      @EndUserText.label: 'Overall Status'
      @Consumption.valueHelpDefinition: [{ entity: { name: '/DMO/I_Overall_Status_VH', element: 'OverallStatus' }}]
      @ObjectModel.text.element: ['OverallStatusText']
      OverallStatus,
      @UI.hidden: true
      _Status._Text.Text as OverallStatusText : localized,
      @UI.hidden: true
      CreatedBy,
      @UI.hidden: true
      CreatedAt,
      @UI.hidden: true
      LastChangedBy,
      @UI.hidden: true
      LastChangedAt,
      /* Associations */
      _Agency,
      _Booking : redirected to composition child Zc_BOOKING_approver_1,
      _currency,
      _Customer,
      _Status
}
