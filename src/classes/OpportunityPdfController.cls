public with sharing class OpportunityPdfController {

    public String RenderedContentType {get; private set;}
    public String RenderingService {get; private set;}
    public List<WrappedOpportunity> AllWrappedOpportunities {get; private set;}
    transient public List<Opportunity> AllOpportunities {get; private set;}
    public Decimal OpportunityTotalAmount {get; private set;}
    public Date EarliestDate {get; private set;}
    public Date LatestDate {get; private set;}

    public OpportunityPdfController() {
        AllOpportunities = [SELECT Id, Name, Amount, StageName, CloseDate FROM Opportunity ORDER By Amount Desc LIMIT 20];
        setRenderAsContendTypeAndFilename();
        calculateTotalAmount();
        wrapAllOpportunities();
    }

    private void setRenderAsContendTypeAndFilename() {
        String filename_to_auto_save_as = 'MyTopOpportunities.pdf';
        RenderedContentType = 'application/pdf#' + filename_to_auto_save_as;
        RenderingService = 'Pdf';
        ApexPages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=' +
                filename_to_auto_save_as);
    }

    private void calculateTotalAmount() {
        EarliestDate = Date.today();
        LatestDate = Date.today().addYears(-500);
        OpportunityTotalAmount = 0.00;
        for (Opportunity each_opp : AllOpportunities) {
            OpportunityTotalAmount += each_opp.Amount;
            if (each_opp.CloseDate < EarliestDate) {
                EarliestDate = each_opp.CloseDate;
            }
            if (each_opp.CloseDate > LatestDate) {
                LatestDate = each_opp.CloseDate;
            }
        }
    }

    private void wrapAllOpportunities() {
        AllWrappedOpportunities = new List<WrappedOpportunity>();
        if (AllOpportunities != null && AllOpportunities.size() >0) {
            Integer counter = 0;
            Boolean is_first = true;
            for (Opportunity each_opportunity : AllOpportunities) {
                AllWrappedOpportunities.add(new WrappedOpportunity(each_opportunity, counter));
                counter++;
            }
        }
    }

    public class WrappedOpportunity {
        private final String SUCCESS = 'images/success.jpg';
        private final String FAILURE = 'images/failure.jpg';
        private final String PENDING = 'images/unknown.jpg';
        private Integer OpportunityCounter;

        public Opportunity Record {get; private set;}


        public WrappedOpportunity(Opportunity each_opportunity, Integer counter) {
            Record = each_opportunity;
            OpportunityCounter = counter;
        }

        public Boolean getIsFirst() {
            return OpportunityCounter == 0;
        }

        public String getImageLink() {
            String image_path = PENDING;
            if (Record.StageName == 'Closed Won') {
                image_path = SUCCESS;
            } else            if (Record.StageName == 'Closed Lost') {
                image_path = FAILURE;
            }
            return image_path;
        }
    }
}