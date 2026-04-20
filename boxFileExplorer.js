import { LightningElement, api, wire } from 'lwc';
import getAllItemsFromFolder from "@salesforce/apex/BoxMethods.getAllItemsFromFolder"
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class BoxFileExplorer extends LightningElement {


    @api
    recordId;
    navigationHistory = [];

    fetchedBoxData = false;
    isFetchingBoxData = false;

    get hasData()
    {
        return this.fetchedBoxData;
    }

    get isEmpty()
    {
        return !this.fetchedBoxData && !this.isFetchingBoxData;
    }

    boxColumnsTitle = [
        { label: 'Name', fieldName: 'name'},
        { label: 'Type', fieldName: 'type' },
        { label:'Click', fieldName: 'btnClick', type: 'button', typeAttributes: {
            label: 'View Details',
            name: 'view_details', // Unique ID for the action
            title: 'Click to view details',
            variant: 'brand', // Options: base, neutral, brand, brand-outline, destructive, success
            iconName: 'utility:preview',
            disabled: false
        }}


        // { label: 'Id', fieldName: 'id' },
        // { label: 'Sequence Id', fieldName: 'sequence_id' },
        // { label: 'Etag', fieldName: 'etag' },
    ];

    boxColumnData;


    
    connectedCallback() {

        this.isFetchingBoxData = true;

        getAllItemsFromFolder({ folderId: '0' })
            .then((result) => {
                console.log(result);
                console.log(JSON.stringify(result));
                

                if(result.isSuccess)
                {
                    if(result.data.entries.length > 0)
                    {
                        this.boxColumnData = result.data.entries;
                        this.fetchedBoxData = true;
                    }
                }
                else{
                    this.dispatchEvent(new ShowToastEvent({
                        title: "Error!",
                        message: result.message,
                        variant: "error"
                    }));
                }

            }).catch((err) => {
                console.log(err);
                console.log(JSON.stringify(err));
                this.dispatchEvent(new ShowToastEvent({
                        title: "Error!",
                        message: err,
                        variant: "error"
                    }));
            }).finally(()=>{
                this.isFetchingBoxData = false;
            });
    }


    handleDataTableRowSelection(event)
    {
        const row = event.detail.row;
        console.log(row);

        const id = row.id;
        navigationHistory.push(id);
        
    }


}