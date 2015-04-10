module Church
  class Checkin < ::Church::Base
    self.table_name = "checkin"
    belongs_to :individual
    has_many :event_attendees
    has_many :nametag_details, class_name: Church::CheckinNametagDetail
    after_initialize :prepare_nametag_id

    def prepare_nametag_id
      self.nametag_id = self.class.build_nametag_id unless nametag_id
    end

    def security_code
      existing = event_attendees.map(&:security_code).uniq.reject {|e| e.blank?}
      existing.empty? ?
        family_security_code :
        existing.first
    end

    def family_security_code
      codes = Church::EventAttendee.family_security_codes_for_date(individual.family.members.ids, checkin)
      if codes.size > 0
        codes.first
      else
        self.class.build_security_code
      end
    end

    def self.build_security_code
      invalid_ids = (current_nametag_ids + current_security_codes).uniq
      begin
        id = ([*('A'..'Z'), *('0'..'9')]).sample(3).join
      end while invalid_ids.include?(id)

      id
    end

    def self.build_nametag_id
      build_security_code.insert(1, "!")
    end

    def self.current_nametag_ids
      pluck(:nametag_id).to_a + exclusion_list
    end

    def self.current_security_codes
      Church::EventAttendee.security_codes_for_date + exclusion_list
    end

    def self.exclusion_list
      %w(
        ASS 666 DAM FUK CUM FUC SUK
        SEX PEE GAY FAG POO EAT HOR
        TIT SHT CNT COK COX FKR FUQ
        PMS KKK CUN CON CUT DIE DUI
        FAT GOD GUT HEX JEW JUG KEG
        KEF KIF KIR LAY LEZ LIE MAD
        MOO NUT RAT RIP RUM SIN SOB
        SOT SUQ QUM QOK QOX DIK VEX
        WET POM WOP YID ABO PUS DIC
        DIQ DIX HOE SOD NGR WSP OMG
        XXX STD HIV H1V FUA FUB FUC
        FUD FUE FUF FUG FUH FUI FUJ
        FUL FUM FUN FUO FUP FUQ FUR
        FUS FUT FUU FUV FUW FUX FUY
        FUZ FU1 FU2 FU3 FU4 FU5 FU6
        FU7 FU8 FU9 FU0 BAD HA8 FRT
        NAG 911 WTF DCK SUC DNR DOA
        BUM BUT FCK SUX VUK PCP
      ).uniq
    end
  end
end
