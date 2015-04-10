class CheckinFamily
  attr_reader :family, :members
  def initialize(family)
    @family = family
    @members = []
    family.members.each do |member|
      @members << CheckinFamilyMember.new(member)
    end
    @members.sort_by! do |i|
      if i.birthday
        Date.today - i.birthday
      else
        1_000_000_000
      end
    end
  end

  def add_events(events)
    members.each do |member|
      member.add_events_for_checkin(events)
    end
  end

  def primary_contact
    @pc ||= (members.select {|m| m.family_position == "h"}.first)
  end

  def spouse
    @sp ||= (members.select {|m| m.family_position == "s"}.first)
  end

  def children
    @ch ||= (members.select {|m| m.family_position == "c"})
  end

  def others
    @oth ||= (members.select {|m| m.family_position == "o"})
  end

  def method_missing(method_name, *args, &block)
    family.send(method_name, *args, &block)
  end
end
