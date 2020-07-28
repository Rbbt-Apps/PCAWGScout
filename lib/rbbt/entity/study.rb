module Study

  property :donor_changes do
    Persist.persist_tsv(nil, "PCAWG Donor changes", {}, :dir => Rbbt.var.PCAWG, :persist => true, :serializer => :double) do |data|
      tsv = TSV.setup({} , :key_field => "Ensembl Protein ID", :fields => ["Donor", "Change"], :type => :double, :namespace => PCAWG.organism)
      incidence = Study.setup("PCAWG").mi_incidence
      TSV.traverse incidence, :into => tsv do |mi,donors|
        next unless mi =~ /ENSP/
        p, change = mi.split(":")
        next if change =~ /([A-Z]):([A-Z*])$/ && $1 == $2

        [p, [donors, [change] * donors.length]]
      end
      tsv.each do |k,v|
        data[k] = v
      end
      data
    end
  end

  property :donor_protein_changes do |protein|
    changes = TSV.setup({}, :key_field => PCAWG::DONOR_FIELD, :fields => ["Change"], :type => :flat, :namespace => PCAWG.organism)
    Misc.zip_fields(donor_changes[protein]).each do |donor, change|
      changes[donor] ||= []
      changes[donor]  << change
    end
    changes
  end
end
